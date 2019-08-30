class CreateLocKhoroos < ActiveRecord::Migration[5.2]
  def change
    create_table :loc_khoroos do |t|
      t.references :loc_district, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
