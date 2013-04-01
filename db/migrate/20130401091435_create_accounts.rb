class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :ac_name
      t.string :sub_domain_name
      t.integer :lms_account_id
      t.integer :is_active

      t.timestamps
    end
  end
end
