class ChangeAttrExpiryDateInUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :expiry_date, :date
  end
end
