class AddMoreAttrToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :name, :string
    add_column :users, :age, :integer
    add_column :users, :weight, :float
    add_column :users, :role, :string, default: 'client'
    add_column :users, :active_plan, :boolean, default: false
  end
end
