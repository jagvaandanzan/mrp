class AddLangToLogistics < ActiveRecord::Migration[5.2]
  def change
    add_column :product_income_logs, :is_match, :boolean, default: false, after: 'description'
  end
end
