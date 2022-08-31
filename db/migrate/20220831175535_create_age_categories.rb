class CreateAgeCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :age_categories do |t|
      t.string :age

      t.timestamps
    end
  end
end
