class UserEnableMailer < ActionMailer::Base
  default from: "santhoshs410@gmail.com" 
  def welcome_email(user)
    @user = user
    @url  = "http://localhost:3000/users/edit"
    headers["X-Spam"] = nil
    mail(:to => user.email, :subject => "Welcome to Institue of Product Leadership Site")
  end
  
end
