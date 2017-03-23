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
            break
          else
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
            #data[:tags] = x.tags
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
          end #end if x.Depreciated
          @annos.push(anno) 
          
	  			end #end for x
	  		end #end for v 
			@annohash = {}
			@annohash[:annotations] = @annos
	  		render :json => @annohash
	  	else
	  		@annohash = {}
			@annohash[:annotations] = @annos
	  		render :json => @annohash
	  	end #end if @videos
	end #end if @location
end #end def getAnnotationsByLocation


################# ADD ANNOTATION BY VIDEO LOCATION

# Add check if annotation text and time and shape match any extant annotations?
def addAnnotation
	@new_id = newAnno(params)
      #format.json { head :ok }
  #respond_to do |format|
    #format.json { head :ok, status :ok}
  #end
  @ret = { head :ok, status :ok}
  render :json => @ret
end #end def addAnnotation
	
  
############ NEW ANNOTATION
private
def newAnno(params)
	@x = params[:annotation]
	  
	## Modified from annotations_controller.rb
	@annotation = Annotation.new
    @annotation.annotation = params[:annotation]
	@annotation.pointsArray = params[:pointsArray]
    @annotation.beginTime = params[:beginTime]
	@annotation.endTime = params[:endTime]
  #@annotation.tags = params[:tags]
    @annotation.user_id = nil#session[:user_id]
    if params[:id]  ## if an old annotation id is supllied, this is an edit and we should create a pointer to the old annotation
    	@annotation.Prev_Anno_ID = params[:id]
    end

      
    @videos = [] 
    @location = params[:location]
    @semantic_tags = SemanticTag.search(params[:semantic_tag]).order("created_at DESC")
 			
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

		if @semantic_tags.empty?
		    @new_tag = SemanticTag.new
			@new_tag.tag = params[:semantic_tag]
			@new_tag.save
			@annotation.tag_id = @new_tag.id
			@annotation.save
		else		
			for t in @semantic_tags
				@annotation.tag_id = t.id
				@annotation.save
			end #end for t
		end #end if @semantic_tags
    else # if video is alrady present
  	  	for x in @videos
		    id_num = x.id
			loc_id = x.location_id	
			@annotation.video_id = id_num
			@annotation.location_id = loc_id
			@annotation.save
				
			if @semantic_tags.empty?
			    @new_tag = SemanticTag.new
			    @new_tag.tag = params[:semantic_tag]
				@new_tag.save
				@annotation.tag_id = @new_tag.id
				@annotation.save
			else		
				for t in @semantic_tags
					@annotation.tag_id = t.id
					@annotation.save
				 end #end for t
			end #end if @semantic_tags		
		end	#end for x
    end #end if @videos
    return @annotation.id  ## returns annotation id of newly created annotation
end #end def newAnno  
  
############ EDIT ANNOTATION   
  
def editAnnotation ## accepts annotation id
    @annot_id = params[:id]   ## original anno id
    dep_array = {}
    dep_array[:id] = @annot_id
    deprecate(dep_array)      ## sets the "deprecated" field of the old annotation to "true"
    new_anno(params)          ## creates new annotation
    
end #end def editAnnotation
  
private
def deprecate(params) ## accepts annotation id, private intra-file function only
    search_term = params[:id]
    @annotation = Annotation.search(search_term).order("created_at DESC")
	if @annotation.present?
      	for x in @annotations
			x.deprecated = true
		end
	end
 end #end def deprecate 
  
 def deleteAnnotation ## accepts annotation id
 	param_array = {}
    param_array[:id] = params[:id]
    #param_array[:updated_pointer] = nil     ## Since we're just "deleting" the annotation, the "updated_pointer" field can point to nil
         ## !!!  (UPDATE: Not including a pointer on the old anno to the new annos, so this is irrelevent)
	deprecate(param_array)
end #end def depreciateAnnotation
  
  
end #end module
