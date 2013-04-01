class AddacIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ac_id, :integer
  end
end
