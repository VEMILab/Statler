require "json"
require 'digest/sha1'

class ApiSessionController < AnnotatorsController

    before_action :user_auth, only: [:login]
    before_action :require_login!, only: [:logout, :addAnnotation, :deleteAnnotation, :editAnnotation]
    

    def getAnnotationByID
        search_term = params[:id]
        annotation = Annotation.find_by(id: params[:id])

        if !annotation
            render :json => { detail: "Could not find annotation id=#{search_term} to delete." }, status: 404
            return
        end

        render :json => annotation.asOpenAnnotationJSON()
    end

    ############ SEARCH ANNOTATION BY LOCATION ############

    def getAnnotationsByLocation
        search_term = params[:location]
        @location = Location.search(search_term).order("created_at DESC") ## pulls location IDs
        @annos = []
        if @location.present?
            @videos = Video.select("id", "title", "author", "location_ID").where(:location_ID => @location)

            if @videos.present?
                for v in @videos
                    @annotations = Annotation.select("beginTime", "endTime", "annotation", "ID", "video_ID", "location_ID", "user_ID", "pointsArray", "deprecated", "tags").where(:video_ID => v.id)
                    for x in @annotations 
                        ## WRAP this next bit in an if/else: if not deprecated, do this, else call function on next newest
                        if x.deprecated
                            next
                        end

                        @annos.push(x.asOpenAnnotationJSON())
                        
                        #@annos.push(anno)
            
                    end #end for x
                end #end for v
            end #end if @videos

            # @annohash = {}
            # @annohash[:annotations] = @annos
        end #end if @location

        render :json => @annos
    end #end def getAnnotationsByLocation

    ############ ADD ANNOTATION BY VIDEO LOCATION ############

    # Add check if annotation text and time and shape match any extant annotations?
    def addAnnotation
        
        ### Create a new Annotation instance
        @annotation = Annotation.new

        # Append body text if supplied
        textSelector = params[:body].select { |item| item[:purpose] == "describing" }
        unless textSelector.empty?
            @annotation.annotation = textSelector.first[:value]
        end

        # Append target points if supplied
        svgSelector = params[:target][:selector].select { |item| item[:type] == "SvgSelector" }
        unless svgSelector.empty?
            # Parse pointsarray from svgSelector[0][:value]
            #svgStr = svgSelector[0][:value]
            #points = svgSelector[/points='(.*?)'/m, 1].strip!.split(" ").map! { |item| item.split(",") }
            @annotation.pointsArray = svgSelector.first[:value]
        end

        timeSelector = params[:target][:selector].select { |item| item[:type] == "FragmentSelector" }
        unless timeSelector.empty?
            timeStr = timeSelector.first[:value]
            timeStr.sub! "t=", ""
            pair = timeStr.split(",")
            @annotation.beginTime = pair.first.to_f * 1000 # Convert to ms
            @annotation.endTime = pair.last.to_f * 1000 # Convert to ms
        else
            # Throw error: time fragment is required.
            render json: { detail: "Time fragment is required." }, status: 422
            return
        end

        #@annotation.tags = params[:tags]
        @annotation.user_id = nil#session[:user_id]

        # Get user ID from auth header
        authType = get_auth_type
        logger.info authType

        # If token auth, get user identity from token and add the information to the annotation
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

            if params[:creator].nil? || params[:creator][:email].nil?
                # Throw an error. Email is required for API auth.
                render json: { detail: "creator.email field is required for API requests!" }, status: 422
                return
            end

            # Set user ID from email address param
            user = User.find_by(email: params[:creator][:email])

            # If user info is specified in the request, pull the user from the db and add its info to the annotation.
            if user
                # Point the annotation to the found user
                @annotation.user_id = user.id
            # Otherwise create a new user from the 
            else
                # Make a new user and point the annotation to that.
                p = Digest::SHA1.hexdigest "default"                
                user = User.new(:name => params[:creator][:email], :email => params[:creator][:email], :password => p, :password_confirmation => p)
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
        @location = Location.search(params[:target][:id]).order("created_at DESC") ## pulls location IDs
        # Find the Video entries for the found Location
        @videos = Video.select("id", "title", "author", "location_ID").where(:location_ID => @location)
        #@videos = Video.search(params[:video_title]).order("created_at DESC")    

        if @videos.empty?	
            ### If there is no Video associated with the Location, create a new one
            # Make and populate Video
            @video = Video.new
            # @video.title = params[:video_title]
            # @video.author = params[:video_author]
            # Make and populate Location
            @new_location = Location.new
            @new_location.location = params[:target][:id]
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

        tagSelectors = params[:body].select { |item| item[:purpose] == "tagging" }
        tags = tagSelectors.map! { |item| item[:value] }

        # Create SemanticTags for new tags
        tags.each do |tagStr|
            # Find or create the SemanticTag for the tag
            tag_entry = SemanticTag.find_or_create_by(tag: tagStr)

            # Make a new TagAnnotation relating tag_entry to the annotation
            tag_annotation = TagAnnotation.new
            tag_annotation.semantic_tag_id = tag_entry.id
            tag_annotation.annotation_id = @annotation.id
            tag_annotation.save
            
        end

        # Remove TagAnnotation relations that are not represented by the tag list (remove deleted tags from annotation).
        if edit_mode && tags
            # Find the TagAnnotations attached to the annotation
            existing_tagannotations = TagAnnotation.where(semantic_tag_id: @annotation.id)

            # Any TagAnnotations that have SemanticTags that aren't in params[:tags] should be removed.
            Array(existing_tagannotations).each do |tag_annotation|
                value = SemanticTag.find_by(id: tag_annotation.semantic_tag_id)
                if !value.in?(tags)
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

        # TODO: Throw an error if the annotation ID is already deprecated
        annotation = Annotation.find(params[:id])
        if annotation.deprecated
            render :json => { detail: "Annotation #{params[:id]} was modified. Please reload the page and try again." }, status: 409
            return
        end
    
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
            render :json => { detail: "Could not find annotation id=#{search_term} to delete." }, status: 404
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