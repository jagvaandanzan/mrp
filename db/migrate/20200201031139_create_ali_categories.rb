class CreateAliCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :ali_categories do |t|
      t.string :name
      t.string :link
      t.references :ali_category, foreign_key: true

      t.timestamps
    end
  end
end
