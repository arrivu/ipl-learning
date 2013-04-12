class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :load_subdomain , :get_sub_domain
  include UrlHelper
  include ActiveMerchant::Billing::Integrations::ActionViewHelper
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def after_sign_in_path_for(resource_or_scope)
    if current_user.has_role? :admin 
     if (request.subdomains[0] != "admin")
     users_path(:subdomain => admin)
    else

      users_path
    end
    
  else
    @subdomain = Account.find_by_id(current_user.ac_id)

    if (current_user.ac_id == @subdomain.id)
     # redirect_to("http://test.lvh.me:3000/")
      # root_path(:subdomain =>( @subdomain.sub_domain_name)) 
      edit_user_registration_url(:subdomain => @subdomain.sub_domain_name)
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

def get_sub_domain
  $sub_domain = request.subdomains[0] 
end

end
