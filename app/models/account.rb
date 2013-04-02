class Account < ActiveRecord::Base
	attr_accessible :ac_name, :is_active, :lms_account_id, :sub_domain_name
	validates :ac_name, presence: true
	validates :lms_account_id, presence: true ,numericality: true, :uniqueness => true
	validates :sub_domain_name, presence: true
	has_many :users
end
