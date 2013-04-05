class UserEnableMailer < ActionMailer::Base
  default from: "santhoshs410@gmail.com" 
  def welcome_email(user,random_string)
    @user = user
    @url  = "http://localhost:3000"
    @password = random_string
    headers["X-Spam"] = nil
    mail(:to => user.email, :subject => "Welcome to Institue of Product Leadership Site")
  end
 
end
