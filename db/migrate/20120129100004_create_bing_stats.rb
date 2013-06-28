class CreateBingStats < ActiveRecord::Migration
  def change
    create_table :bing_stats do |t|
      t.string :url
      t.integer :http_code
      t.string :response_type

      t.timestamps
    end
  end
end
