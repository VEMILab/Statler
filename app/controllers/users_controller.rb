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
    par = user_params

    name = par[:name]
    # SHA1 the email and password
    email = Digest::SHA1.hexdigest par[:email].to_s
    pass = Digest::SHA1.hexdigest par[:password].to_s
    pass_conf = Digest::SHA1.hexdigest par[:password_confirmation].to_s

    user = User.new(:name => name, :email => email, :password => pass, :password_confirmation => pass_conf)
    if user.save
      session[:user_id] = user.id
      redirect_to '/'
    else
      redirect_to '/signup'
    end
  end

private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
