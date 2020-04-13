class AddProdToAliFilterGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :ali_filter_groups, :prod, :boolean, default: 0, after:'name_mn'
    add_column :ali_filters, :prod, :boolean, default: 0, after:'name_mn'
  end
end
