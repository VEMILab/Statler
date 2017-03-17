module WelcomeHelper
	def welcome_helper
	  #check to see if username field is blank or null
	  if params[:username].present? #!= ("" or nil)
		  @username = params[:username]
		  #@password = params[:password]
		  #fetch users from database
		  @users = User.search(params[:username]).order("created_at DESC")
		  #initialize valid_login as empty	
		  @valid_login = []
			  #if there are users in the database
			  if @users.present?
				for x in @users
 				     @valid_login << User.select("name").where(:name => @username)
 				end
				if @valid_login.empty?
					@return = "Sorry, this is not a valid username. Would you 							  like to log in?"
				else
					@return = "This is a valid username!"
				end
			  else	
				@return = "Sorry, this is not a valid username. Would you like to 						   log in?"
		    	  end
	else
		@return = "Would you like to log in?"

	
	end 
	return @return.to_s
end 
end

