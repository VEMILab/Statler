module AnnotatorsHelper
	

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
					@annos.push(anno)
          
	  		end #end for x
	  	end #end for v 
	  end #end if @videos

		@annohash = {}
		@annohash[:annotations] = @annos
		render :json => @annohash
	end #end if @location
end #end def getAnnotationsByLocation


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
		### If there are Videos associated with the Location, update the annotation to reference these.
		for video in @videos
			@annotation.video_id = video.id
			@annotation.location_id = video.location_id	
			@annotation.save
		end
  end

	### Handle tags

	# Create SemanticTags for new tags
	Array(params[:tags]).each do |tagStr|
		# Check to see if the tag already exists
		#tag_check = SemanticTag.search(t).order("created_at DESC")
		tag_check = SemanticTag.find_by(tag: tagStr)
		# If it doesn't, make a new SemanticTag and relate it to the annotation.	
		if tag_check.nil?
			logger.info "Making new SemanticTag for \"" + tagStr + "\""
			new_tag = SemanticTag.new
			new_tag.tag = tagStr
			new_tag.save

			tag_annotation = TagAnnotation.new
			tag_annotation.semantic_tag_id = new_tag.id
			tag_annotation.annotation_id = @annotation.id
			tag_annotation.save
		else
			logger.info "\"" + tagStr + "\" already has a SemanticTag"
		end
	end

	# Remove SemanticTags that are not represented by the tag list (remove deleted tags).



	# unless @semantic_tag_check_old.empty?
	# 	# iterate through tags that were previously in the db, edit
	# 	@semantic_tag_check_old.each do |t|
	# 		#@annotation.tag_id = t.id
	# 		@tag_annotation.semantic_tag_id = t.id
	# 		@tag_annotation.annotation_id = @annotation.id
	# 		@annotation.save
	# 		@tag_annotation.save
	# 	end
	# end	

	# unless @semantic_tag_check_new.empty?
	# 	# iterate through tags that are new to the db, create/edit
	# 	@semantic_tag_check_new.each do |t|
	# 		new_tag = SemanticTag.new
	# 		new_tag.tag = t
			
	# 		@tag_annotation.semantic_tag_id = new_tag.id
	# 		@tag_annotation.annotation_id = @annotation.id
	# 		@annotation.save
	# 		@tag_annotation.save
	# 		@semantic_tags.save
	# 	end
	# end #end if @semantic_tags
    
  @ret = {}
  @ret[:id] = @annotation.id
  #@ret[:status] = 200
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
	anno.update(deprecated: true)

end
  
  
end #end module
