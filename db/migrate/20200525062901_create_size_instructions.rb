class CreateSizeInstructions < ActiveRecord::Migration[5.2]
  def change
    create_table :size_instructions do |t|
      t.integer :queue, default: 0
      t.string :instruction

      t.timestamps
    end
  end
end
