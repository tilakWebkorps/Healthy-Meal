class ChangeForDayInDay < ActiveRecord::Migration[6.1]
  def change
    change_column :days, :for_day, :string
  end
end
