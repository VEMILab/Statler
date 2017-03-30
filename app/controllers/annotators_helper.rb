module AnnotatorsHelper
	

##################### SEARCH ANNOTATION BY LOCATION

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


################# ADD ANNOTATION BY VIDEO LOCATION

# Add check if annotation text and time and shape match any extant annotations?
def addAnnotation
	@x = params[:annotation]
	  
	## Modified from annotations_controller.rb
	@annotation = Annotation.new
  @annotation.annotation = params[:annotation]
	@annotation.pointsArray = params[:pointsArray]
  @annotation.beginTime = params[:beginTime]
	@annotation.endTime = params[:endTime]
  #@annotation.tags = params[:tags]
  @annotation.user_id = nil#session[:user_id]
  if params[:id]  ## if an old annotation id is supplied, this is an edit and we should create a pointer to the old annotation
    @annotation.prev_anno_ID = params[:id]
  end

      
  @videos = [] 
  @location = params[:location]

	#logger.info params[:semantic_tag]

  @tag_check = []	
  @semantic_tag_check_old = []
  @semantic_tag_check_new = []

	#if semantic tags are present
  unless params[:tags].nil?
		#for each element in the array
		params[:tags].each do |tag|
			#individually check to see if it already exists
			tag_check = SemanticTag.search(tag).order("created_at DESC")
			#if it does, add to existing semantic tags array, if not add to new semantic tag array			
			if !tag_check.empty?
				@semantic_tag_check_old.push(tag_check.tag)
			else
			  @semantic_tag_check_new.push(tag)
			end
		end
	end
	#end
	
	@location = Location.search(@location).order("created_at DESC") ## pulls location IDs
	#if @location.present?
	@videos = Video.select("id", "title", "author", "location_ID").where(:location_ID => @location)
  #@videos = Video.search(params[:video_title]).order("created_at DESC")    
  if @videos.empty?	
	  @video = Video.new
    @video.title = params[:video_title]
		@video.author = params[:video_author]
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
		for x in @videos
			id_num = x.id
			loc_id = x.location_id	
			@annotation.video_id = id_num
			@annotation.location_id = loc_id
			@annotation.save

		end	#end for x

  end #end if @videos

	# if @semantic_tags_check_old	
	# 	# iterate through tags that were previously in the db, edit
	# 	for t in @semantic_tag_check_old
	# 		#@annotation.tag_id = t.id
	# 		@tag_annotation.semantic_tag_id = t.id
	# 		@tag_annotation.annotation_id = annotation.id
	# 		@annotation.save
	# 		@tag_annotation.save
	# 	end
	# end	
	# if @semantic_tag_check_new
	# 	# iterate through tags that are new to the db, create/edit
	# 	for t in @semantic_tag_check_new
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
	

  
############ EDIT ANNOTATION   
  
def editAnnotation ## accepts annotation id
  
	# Deprecate the old annotation
  deleteAnnotation
    
	# Create a new annotation linking back to the old one.
  addAnnotation
end #end def editAnnotation
  
###### DELETE ANNOTATION  
def deleteAnnotation ## accepts annotation id
  search_term = params[:id]
	# Find the annotation with the given ID
	anno = Annotation.find_by(id: search_term)
	anno.update(deprecated: true)

end
  
  
end #end module
