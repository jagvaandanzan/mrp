class CreateCustomerContacts < ActiveRecord::Migration[5.2]
  def change
    # add_foreign_key :products, :users
    add_column :loc_districts, :country, :boolean, default: false, after:'name'
    add_column :locations, :micro_region, :string, after: 'loc_khoroo_id'
    add_column :locations, :town, :string, after: 'micro_region'
    add_column :locations, :street, :string, after: 'town'
    add_column :locations, :apartment, :string, after: 'street'
    add_column :locations, :entrance, :string, after: 'apartment'

    add_reference :locations, :station, foreign_key: {to_table: :locations}, after: 'loc_khoroo_id'
  end
end
