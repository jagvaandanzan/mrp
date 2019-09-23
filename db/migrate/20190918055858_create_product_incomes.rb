class CreateProductIncomes < ActiveRecord::Migration[5.2]
  def change
    create_table :product_incomes do |t|
      t.string :code
      t.datetime :income_date
      t.string :note
      t.references :supplier

      t.timestamps
    end
  end
end
