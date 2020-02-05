class CreateAliFilterGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :ali_filter_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
