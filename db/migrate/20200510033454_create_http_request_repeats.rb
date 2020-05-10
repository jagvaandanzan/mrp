class CreateHttpRequestRepeats < ActiveRecord::Migration[5.2]
  def change
    create_table :http_request_repeats do |t|
      t.text :url
      t.string :method
      t.text :param

      t.timestamps
    end
  end
end
