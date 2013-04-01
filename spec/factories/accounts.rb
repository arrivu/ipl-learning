# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account do
    ac_name "MyString"
    sub_domain_name "MyString"
    lms_account_id 1
    is_active 1
  end
end
