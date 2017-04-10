class AnnotationsController < ApplicationController

    before_action :authorize

  # POST /annotations

    def authorize
        if !session[:current_user]
            redirect_to '/login'
        end

        THROW AN ERROR PLS
    end


  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def create

  ##  before_action :authorize

    @annotation = Annotation.new
    @annotation.annotation = params[:annotation]
    @annotation.user_id = session[:user_id]
    @videos = []

    
    
    
    # Separates tag string into individual tags
    #@input_semantic_tags = :semantic_tag.split(",")
    # Deletes a tag if it's an empty string -- useful in case someone puts a double comma
    #@input_semantic_tags.delete_if{|t| t.length == 0}
    
    #@semantic_tags = SemanticTag.search(params[:semantic_tag]).order("created_at DESC")
    @semantic_tags = SemanticTag.search(params[@input_semantic_tags]).order("created_at DESC")

    @point_array = []
    #these are just example points. 
    #in the front end, a GUI button can be clicked to initiate the polygon creation process
    #following that, each single click stores a point in an array
    #double-click finalizes the polygon and ends creation process
    #points are treated as strings and stored with delimiter in between 
    point1 = "5,0"
    @point_array.push(point1) 
    point2 = "5,5"
    @point_array.push(point2) 
    point3 = "0,5"
    @point_array.push(point3) 
    point4 = "0,0"
    @point_array.push(point4) 
 
    @annotation.polygon = @point_array.to_s

    @semantic_tags = SemanticTag.search(params[:semantic_tag]).order("created_at DESC")
    #@semantic_tags = SemanticTag.search(params[@input_semantic_tags]).order("created_at DESC")
   # @existing_tags = []

   
   
    @videos = Video.search(params[:video_title]).order("created_at DESC")    
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
	
	# if @semantic_tags.size() < @input_semantic_tags.size() 
	# then make new tag entries for missing ones
	# -- not best logic, probably do a differential search earlier on in file
	
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
		end
	
	end

    else
    	for x in @videos
		id_num = x.id
		loc_id = x.location_id	
		@annotation.video_id = id_num
		@annotation.location_id = loc_id
		@annotation.save		
	end	

    end
	
  #    if @annotation.save && (@video.save || @location.save || @new_tag.save)
    #    @message = 'Annotation was successfully created.'
   #   else
   #     @message = 'There has been an error.'
   #   end
  #  puts @message
    end
end

