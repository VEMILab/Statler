require "json"
require 'digest/sha1'

class ApiSessionController < AnnotatorsController

    before_action :user_auth, only: [:login]
	before_action :require_login!, only: [:logout, :addAnnotation, :deleteAnnotation, :editAnnotation]

    ############ SEARCH ANNOTATION BY LOCATION ############

    def getAnnotationsByLocation
        search_term = params[:location]
        @location = Location.search(search_term).order("created_at DESC") ## pulls location IDs
        if @location.present?
            @videos = Video.select("id", "title", "author", "location_ID").where(:location_ID => @location)
            @annos = []

            if @videos.present?
                for v in @videos
                    @annotations = Annotation.select("beginTime", "endTime", "annotation", "ID", "video_ID", "location_ID", "user_ID", "pointsArray", "deprecated", "tags").where(:video_ID => v.id)
                    for x in @annotations 
                        ## WRAP this next bit in an if/else: if not deprecated, do this, else call function on next newest
                        if x.deprecated
                            next
                        end

                        tag_strings = x.semantic_tags.collect(&:tag)

                        #@annos.push(getAnnotationInfo(x)) <-- originally started pulling functionality into private function, added complexity seemed to outweigh readability
                        video = Video.select("title", "location_ID").where(:ID => x.video_id)
                        location = Location.select("location").where(:ID => x.location_id)
                        user = User.select("name", "email").where(:ID => x.user_id)	
                        anno = {}

                        data = {}
                        data[:text] = x.annotation
                        data[:beginTime] = x.beginTime
                        data[:endTime] = x.endTime
                        data[:pointsArray] = x.pointsArray
                        data[:tags] = tag_strings

                        meta = {}
                        meta[:id] = x.id
                        meta[:title] = video[0].title
                        meta[:location] = location[0].location
                        unless user[0].nil?
                            meta[:userName] = user[0].name
                            meta[:userEmail] = user[0].email
                        end

                        anno[:data] = data
                        anno[:metadata] = meta

                        # Form open annotation from constructed annotation
                        open_annotation = as_open_annotation(anno)
                        @annos.push(open_annotation)
                        
                        #@annos.push(anno)
            
                    end #end for x
                end #end for v
            end #end if @videos

            @annohash = {}
            @annohash[:annotations] = @annos
            render :json => @annohash
        end #end if @location
    end #end def getAnnotationsByLocation

    def as_open_annotation(annotation)
        oa = {}
        oa[:@context] = "http://www.w3.org/ns/anno.jsonld"
        oa[:type] = "Annotation"
        oa[:motivation] = "highlighting"

        if annotation[:metadata][:userName] && annotation[:metadata][:userEmail]
            username = annotation[:metadata][:userName]
            email = Digest::SHA1.hexdigest annotation[:metadata][:userEmail]
            oa[:creator] = {
                type: "Person",
                nickname: username,
                # SHA1 email address
                email:
            }
        end

        body = []
        # Create text descriptor
        body.push({
            type: "TextualBody",
            value: annotation[:data][:text],
            format: "text/plain",
            language: "en",
            purpose: "describing"
        })

        # Add tag descriptors
        for tag in annotation[:data][:tags]
            body.push({
                type: "TextualBody",
                purpose: "tagging",
                value: tag
            })
        end
        
        oa[:body] = body


        target = {
            id: annotation[:metadata][:location],
            type: "Video"
        }

        target_selectors = []

        # Add polygon selector (spatial)
        points = annotation[:data][:pointsArray]
        unless points.nil?
            # Get 2D array from string
            points_array = JSON.parse(points)

            points_string = ""
            for item in points_array
                # Convert from coordinate point string pairs to float pairs
                raw_point = item.map(&:to_f)
                # Add to the points string
                points_string += "#{raw_point[0]},#{raw_point[1]} "
            end
            svgHTML = "<svg:svg viewBox='0 0 100 100' preserveAspectRatio='none'><polygon points='#{points_string}' /></svg:svg>"
            target_selectors.push({
                type: "svgSelector",
                value: svgHTML
            })
        end

        # Add temporal selector
        beginTimeSeconds = annotation[:data][:beginTime].to_i / 1000
        endTimeSeconds = annotation[:data][:endTime].to_i / 1000
        target_selectors.push({
            type: "FragmentSelector",
            conformsTo: "http://www.w3.org/TR/media-frags/",
            value: "t=#{beginTimeSeconds},#{endTimeSeconds}"
        })

        target[:selector] = target_selectors

        oa[:target] = target
        return oa
    end


    ############ ADD ANNOTATION BY VIDEO LOCATION ############

    # Add check if annotation text and time and shape match any extant annotations?
    def addAnnotation
        @x = params[:annotation]
        
        ### Create a new Annotation instance
        @annotation = Annotation.new
        @annotation.annotation = params[:annotation]
        @annotation.pointsArray = params[:pointsArray]
        @annotation.beginTime = params[:beginTime]
        @annotation.endTime = params[:endTime]
        #@annotation.tags = params[:tags]
        @annotation.user_id = nil#session[:user_id]

        # Get user ID from auth header
        authType = get_auth_type
        logger.info authType
        if authType == "Token"
            # Set user ID from auth token
            authHeader = request.headers["HTTP_AUTHORIZATION"]
            auth = authHeader.split(" ").last
            pair = auth.split("=")
            user = User.find_by(token: pair.last)
            if user
                @annotation.user_id = user.id
            end
        elsif authType == "ApiKey"
            # Set user ID from email address param
            user = User.find_by(email: params[:email])

            if user
                # Point the annotation to the found user
                @annotation.user_id = user.id
            else
                # Make a new user and point the annotation to that
                user = User.new(:name => params[:email], :email => params[:email], :password => "pass", :password_confirmation => "pass")
                user.save
                @annotation.user_id = user.id
            end
        end

        edit_mode = false
        if params[:id]  ## if an old annotation id is supplied, this is an edit and we should create a pointer to the old annotation
                edit_mode = true
            @annotation.prev_anno_ID = params[:id]
        end

        #logger.info params[:semantic_tag]
        
        # Find the Location entry for the URL
        @location = Location.search(params[:location]).order("created_at DESC") ## pulls location IDs
        # Find the Video entries for the found Location
        @videos = Video.select("id", "title", "author", "location_ID").where(:location_ID => @location)
        #@videos = Video.search(params[:video_title]).order("created_at DESC")    

        if @videos.empty?	
            ### If there is no Video associated with the Location, create a new one
            # Make and populate Video
            @video = Video.new
            @video.title = params[:video_title]
            @video.author = params[:video_author]
            # Make and populate Location
            @new_location = Location.new
            @new_location.location = params[:location]
            @new_location.save
            @video.save
            @video.location_id = @new_location.id
            @annotation.video_id = @video.id
            @annotation.location_id = @new_location.id
            @video.save
            @annotation.save

        else # if video is already present
            ### If there are Video entries associated with the Location, update the annotation to reference these.
            for video in @videos
                @annotation.video_id = video.id
                @annotation.location_id = video.location_id	
                @annotation.save
            end
        end

        ### Handle tags

        # Create SemanticTags for new tags
        Array(params[:tags]).each do |tagStr|
            # Find or create the SemanticTag for the tag
            tag_entry = SemanticTag.find_or_create_by(tag: tagStr)

            # Make a new TagAnnotation relating tag_entry to the annotation
            tag_annotation = TagAnnotation.new
            tag_annotation.semantic_tag_id = tag_entry.id
            tag_annotation.annotation_id = @annotation.id
            tag_annotation.save
            
        end

        # Remove TagAnnotation relations that are not represented by the tag list (remove deleted tags from annotation).
        if edit_mode && params[:tags]
            # Find the TagAnnotations attached to the annotation
            existing_tagannotations = TagAnnotation.where(semantic_tag_id: @annotation.id)

            # Any TagAnnotations that have SemanticTags that aren't in params[:tags] should be removed.
            Array(existing_tagannotations).each do |tag_annotation|
                value = SemanticTag.find_by(id: tag_annotation.semantic_tag_id)
                if !value.in?(params[:tags])
                    # Remove the TagAnnotation from TagAnnotations
                    tag_annotation.destroy
                end
            end
            
        end
        
        @ret = {}
        @ret[:id] = @annotation.id
        render :json => @ret
    end #end def addAnnotation
        

    
    ############ EDIT ANNOTATION ############
    
    def editAnnotation ## accepts annotation id
    
        # Deprecate the old annotation
        deleteAnnotation
        
        # Create a new annotation linking back to the old one.
        addAnnotation
    end #end def editAnnotation
    
    ############ DELETE ANNOTATION ############

    def deleteAnnotation ## accepts annotation id
        search_term = params[:id]
        # Find the annotation with the given ID
        anno = Annotation.find_by(id: search_term)
        if anno
            anno.update(deprecated: true)
            # head :no_content
        else
            render :json => { errors: [ { detail: "Could not find annotation id=#{search_term} to delete." } ] }, status: 404
        end

    end

    def login
        # Render the login info for the frontend to save.
        header = request.headers["HTTP_AUTHORIZATION"]
        token = header.split(" ").last
        pair = Base64.decode64(token).split(":")
        user = User.find_by_name(pair.first)
        
        auth_token = user.generate_auth_token
        render json: { auth_token: auth_token }
        
    end

    def logout
        header = request.headers["HTTP_AUTHORIZATION"]
        token = header.split(" ").last
        user = User.find_by(token: token)
        if user
            user.invalidate_auth_token
            head :no_content
        else
            render :json => { detail: "Could not log user out - token matches no users" }, status: 200
        end
    end
    

    def generateKey
        application_name = params[:application_name]

        apikey = ApiKey.new  # Create
        apikey.application_name = application_name
        apikey.api_key = SecureRandom.uuid
        apikey.save  # Finalize and save

        render :json => apikey

    end




end