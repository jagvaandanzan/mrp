class CreateTechnicalSpecifications < ActiveRecord::Migration[5.2]
  def change
    create_table :technical_specifications do |t|
      t.string :specification

      t.timestamps
    end
  end
end
