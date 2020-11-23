class CreateSalesmanReturnSigns < ActiveRecord::Migration[5.2]
  def change
    create_table :salesman_return_signs do |t|
      t.references :salesman, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.attachment :given
      t.attachment :received

      t.timestamps
    end
  end
end
