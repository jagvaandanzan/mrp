class CreateAliFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :ali_filters do |t|
      t.references :ali_filter_group, foreign_key: true
      t.string :name
      t.string :img

      t.timestamps
    end
  end
end
