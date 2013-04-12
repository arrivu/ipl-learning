# == Schema Information
#
# Table name: users
#

#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
# 
#  phone                  :string(255)
#  user_type              :string(255)
#  sub_plan               :string(255)
#  user_desc              :string(255)
#  name                   :string(255)
#  username               :string(255)

#

class User < ActiveRecord::Base
  include CasHelper
  include LmsHelper


  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable , :lockable, :timeoutable and :omniauthable, :confirmable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook,:google_oauth2,:linkedin]
  if Rails.env.production?
    devise :confirmable
  end
  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids,:is_active, :as => :admin
  attr_accessible :attachment,:content_type,:image_blob,:lms_id,:name,
  :email, :password, :password_confirmation, :remember_me, :omni_image_url,
  :phone,:user_type,:sub_plan,:user_desc, :provider,:ac_id,:is_active, :uid ,
  :confirmed_at

  has_many :courses, dependent: :destroy
  has_many :o_classes, :class_name => "O_Classe"
  # has_many :tutorials, dependent: :destroy
  has_many :blogs, dependent: :destroy
  has_many :authentication, :dependent => :delete_all

  has_many :comments
  belongs_to :account
  # has_one :teaching_staffs, dependent: :destroy
  # has_one :students, dependent: :destroy




  letsrate_rater
  def apply_omniauth(auth)
	  # In previous omniauth, 'user_info' was used in place of 'raw_info'
    self.email    = auth['info']['email']
    self.name     = auth['info']['name']
    self.omni_image_url = auth['info']['image']
    self.phone    = auth['info']['phone']
    self.provider = auth['provider']

    require 'bcrypt'

    pepper = nil
    cost = 10
    encrypted_password = ::BCrypt::Password.create("#{Time.now.to_s}#{pepper}", :cost => cost).to_s
    self.encrypted_password = encrypted_password

	  # Again, saving token is optional. If you haven't created the column in authentications table, this will fail
	  authentication.build(:provider => auth['provider'], :uid => auth['uid'], :token => auth['credentials']['token'])
	end

  def attachment=(incoming_file)
    self.content_type = incoming_file.content_type
    self.image_blob = incoming_file.read
  end



  
  before_destroy:delete_in_lms
  def delete_in_lms
    if lms_enable? 
      lmsuser=CanvasREST::User.new
      lmsuser.set_token(Settings.lms.oauth_token,Settings.lms.api_root_url)
      lmsuser.delete_user(Settings.lms.account_id,self.lms_id)
    end
  end

  def active_for_authentication?
    super && is_active?
  end
  
  #omniauth facebook with devise
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.new(name:auth.extra.raw_info.name,
       provider:auth.provider,
       uid:auth.uid,
       email:auth.info.email,
       omni_image_url: auth.info.image,
       phone: auth.info.phone,
       password:Devise.friendly_token[0,20],
       confirmed_at:Time.now
       )

          user.ac_id=$account.id unless $account.id == nil
      user.save
    end
    if Rails.env.production?
      user.skip_confirmation! 
    end

    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
  #omniauth google oauth with devise
  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.new(name: data["name"],
       email: data["email"],
       omni_image_url: data["image"],
       password: Devise.friendly_token[0,20],
       confirmed_at:Time.now
       )
       user.ac_id=$account.id unless $account.id == nil
      user.save
    end
    if Rails.env.production?
      user.skip_confirmation! 
    end
    user
  end

  #omniauth linkedin with devise
  def self.find_for_linkedin(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first
    unless user
      user = User.new(name: data["name"],
       email: data["email"],
       omni_image_url: data["image"],
       password: Devise.friendly_token[0,20],
       confirmed_at:Time.now
       )
        user.ac_id=$account.id unless $account.id == nil
      user.save
    end
    if Rails.env.production?
      user.skip_confirmation! 
    end
    user
  end
end
