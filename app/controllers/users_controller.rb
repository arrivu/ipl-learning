class UsersController < ApplicationController
  before_filter :authenticate_user!
  
  
  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end
  
  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user], :as => :admin)
      if params[:user][:is_active] == "0"
        redirect_to users_path, :notice => "User updated."
      else
       # Tell the UserMailer to send a welcome Email after save
       UserEnableMailer.welcome_email(@user).deliver
       redirect_to users_path
       flash[:info]= "User updated and activation mail sent !"
     end
   else

    redirect_to users_path, :alert => "Unable to update user."
  end
end

def destroy
  authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
  user = User.find(params[:id])
  unless user == current_user
    user.destroy
    redirect_to users_path, :notice => "User deleted."
  else
    redirect_to users_path, :notice => "Can't delete yourself."
  end
end

end