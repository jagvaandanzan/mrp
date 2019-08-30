class CreateLocDistricts < ActiveRecord::Migration[5.2]
  def change
    create_table :loc_districts do |t|
      t.string :name

      t.timestamps
    end
  end
end
