module SearchHelper
	def search_helper
    if params[:search] 
	    if params[:search].include? "\""
			anno_query = params[:search].tr "\"", "" 
	    else
			anno_query = params[:search]	
	    end
	    #if search value was passed through url, search method of Annotation model is initiated
        @annotations = Annotation.search(anno_query).order("created_at DESC")
        @returns = []
        if @annotations.present? 	
	    	for x in @annotations
            	@returns.push(x)
            end #end of for x in annotations
	    end	#end of if @annotations    
	end #end of if params
	
	if params[:searchtag] 	
	    #if search value was passed through url, search method of SemanticTag model is initiated
    	@tags = SemanticTag.search(params[:searchtag]).order("created_at DESC")
        @returns = []
        if @tags.present? 
	    for t in @tags	
			@annotations = Annotation.select("annotation", "video_ID", "location_ID", "user_ID").where(:tag_ID => t.id)
	    end
	    for x in @annotations 
         	@returns.push(x)   
      	end #end of for x in annotations
	end	#end of if @annotations    
end #end of if params
  
    return @returns
end #end of def search_helper

#this allows for the display of annotations contributed by the logged-in user
def user_content_helper
		#if the user is logged in
		@returns = []
		if session[:user_id]
		 	@annotations = Annotation.search(params[:search]).order("created_at DESC")
		 	user_annotations = []
	
			user_annotation = []			
			user_id = session[:user_id]				
			user_annotation = Annotation.select("annotation", "id", "video_id").where(:user_id => user_id)
			if !user_annotation.empty?
				for x in user_annotation
					@returns.push(x)#.to_json)
				end
			end			
			if @returns.empty?#[0].empty?
				@str = "You have not submitted any annotations."
				@returns.push(@str)
			end
		else
			@str = "You need to be logged in to see annotations that you have submitted."
			@returns.push(@str) 
		end
		return @returns

end
end #end of module
