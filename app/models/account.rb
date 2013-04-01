class Account < ActiveRecord::Base
  attr_accessible :ac_name, :is_active, :lms_account_id, :sub_domain_name
  has_many :users
end
