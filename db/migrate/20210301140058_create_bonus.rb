class CreateBonus < ActiveRecord::Migration[5.2]
  def change
    create_table :bonus do |t|
      t.integer :balance

      t.timestamps
    end

    create_table :bonus_phones do |t|
      t.references :bonu, null: false, foreign_key: true
      t.integer :phone

      t.timestamps
    end

    create_table :bonus_balances do |t|
      t.references :bonu, null: false, foreign_key: true
      t.references :product_sale, foreign_key: true
      t.references :product_sale_item, foreign_key: true
      t.integer :bonus

      t.timestamps
    end
  end
end
