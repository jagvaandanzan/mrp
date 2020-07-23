class CreateShippingErs < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_ers do |t|
      t.references :logistic, null: false, foreign_key: true
      t.datetime :date
      t.text :description

      t.timestamps
    end
  end
end