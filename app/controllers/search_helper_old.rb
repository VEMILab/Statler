module SearchHelper
	def search_helper
          if params[:search] 	
	    #if search value was passed through url, search method of Annotation model is 		    initiated
            @annotations = Annotation.search(params[:search]).order("created_at DESC")
	  else
	   # @annotations = Annotation.all.order('created_at DESC')
	  end


	if @annotations.present? 	
	   for x in @annotations
		queries = video_id.find(:all)
           end
	   for query in queries
		@videos << Video.search(query).order("created_at DESC")
	   end
	else
	   @videos = []
	end

	if @videos.present?
	   for x in @annotations
		queries = location_id.find(:all)
	   end
	   for query in queries
	   	@locations << Location.search(query).order("created_at DESC")
	   end
	else
	   @locations = []
	end
	return @annotations.to_s, @videos.to_s, @locations.to_s
   end
end
