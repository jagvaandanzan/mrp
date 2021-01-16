class CreateSalesmanTracks < ActiveRecord::Migration[5.2]
  def change
    create_table :salesman_tracks do |t|
      t.references :salesman, null: false, foreign_key: true
      t.decimal :latitude, {:precision => 10, :scale => 6}
      t.decimal :longitude, {:precision => 10, :scale => 6}

      t.timestamps
    end
  end
end
