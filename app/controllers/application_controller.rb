class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_subdomain
  include UrlHelper
  include ActiveMerchant::Billing::Integrations::ActionViewHelper
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def after_sign_in_path_for(resource_or_scope)
    if current_user.has_role? :admin 
     if (request.subdomains[0] != "admin")
      reset_session
      cookies.delete :tgt
      flash[:error] = "You cannot login admin from this domain"
      new_user_session_path
    else

      users_path
    end
    
  else
    @subdomain = Account.find_by_sub_domain_name!(request.subdomain)
    
    if (current_user.ac_id ==@subdomain.id)
      edit_user_registration_path  
    else
      reset_session
      cookies.delete :tgt
      flash[:error] = "You are login with incorrect url"
      new_user_session_path
    end 
  end    
end
def load_subdomain
  if(request.subdomains[0] != nil)
    @subdomain = self.request.subdomains[0] || 'local'
    
  else
    @subdomain = "common"
  end

end
end
