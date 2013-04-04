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
       begin
         UserEnableMailer.welcome_email(@user).deliver
         flash[:info]= "User updated and activation mail sent !"

       rescue => e
        flash[:info] = "There is some error while sending the email .[ #{e.message}]"

      end
      redirect_to users_path
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

def add_users
log=Logger.new("./test.Logger")
log.debug params[:activate]
  if(params[:file] != nil && params[:user_emails]!= "")
    flash[:error] = "Please give any one input"
    redirect_to (account_path(params[:ac_id]))
  elsif (params[:file] == nil && params[:user_emails]== "")
    flash[:error] = "Please give any one input"
    redirect_to (account_path(params[:ac_id]))
  else

    if (params[:file] == nil)
      params[:user_emails].split(",").each do |email|
        @post = User.new(:email => email ,:password => "123456789" , :ac_id => params[:ac_id] , :is_active => params[:activate] )
        
        if @post.save
          
          $error =nil
        end
      end        

    else
      require 'spreadsheet'
      file = params[:file]
      acid =params[:ac_id]
      case File.extname(file.original_filename)
      when ".csv" then
        CSV.foreach(file.path) do |row|
          email =row[0]
          @post =User.new(:email => email ,:password => "123456789" , :ac_id => acid , :is_active => params[:activate])
          if @post.save
            $error =nil

          end
        end
      when ".txt" then
       data=""
       File.open(file.path).each_line do |line|
        data += line
      end
      data.split(",").each do |email|

        @post =User.new(:email => email ,:password => "123456789" , :ac_id => acid , :is_active => params[:activate])
        if @post.save
          $error =nil
        end
      end
    when ".xls" || "xlsx" then
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet.open(file.path, :col_sep => ',', :headers => true )
      sheet1 = book.worksheet 0
      sheet1.each do |row|
        email =row[0]
        @post =User.new(:email => email ,:password => "123456789" , :ac_id => acid , :is_active => params[:activate])
        if @post.save
          $error =nil
        end
      end
    else raise "Unknown file type: #{file.original_filename}"
    end

  end
  respond_to do |format|
    if @post.save
      $error =nil
      format.js
      format.html { redirect_to (account_path(params[:ac_id])) }
      flash[:success] = "user added to account successfully!!!!"
      format.xml  { render :xml => @post, :status => :created, :location => @post }
    else
      $error =nil
      format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }

      format.html { redirect_to (account_path(params[:ac_id])) }
      $error = @post

    end
  end
end

end

end