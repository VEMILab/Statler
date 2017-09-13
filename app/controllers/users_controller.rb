class UsersController < ApplicationController

  def new
  end

  def create
    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id
      redirect_to '/'
    else
      redirect_to '/signup'
    end
  end

  def createFromForm
    # SHA1 the email and password
    email = Digest::SHA1.hexdigest :email
    pass = Digest::SHA1.hexdigest :password
    pass_conf = Digest::SHA1.hexdigest :password_confirmation

    create(:name => :name, :email => email, :password => pass, :password_confirmation => pass_conf)
  end

private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
