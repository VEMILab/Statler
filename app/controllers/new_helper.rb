module NewHelper
	def new_helper
		@username = params[:username]
		@email = params[:email]
		@password = params[:password]
		new_user = User.new(:name => @username, :email => @email, :pass => @password)
		new_user.save
		@return = "Successfully created new user!"
		return @return 	
	end	
end
