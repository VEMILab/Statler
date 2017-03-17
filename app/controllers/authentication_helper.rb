module WelcomeHelper
	def welcome_helper
	  @username = params[:username]
	  @password = params[:password]
	  if @username.present
		@return = "This is a valid username!"
	  else
		@return = "Would you like to log in?"
    	  end
	return @return
    end 
end 
