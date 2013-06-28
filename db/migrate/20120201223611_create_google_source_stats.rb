class CreateGoogleSourceStats < ActiveRecord::Migration
  def change
    create_table :google_source_stats do |t|
      t.string :url
      t.string :linked_from
      t.datetime :discovery_date

      t.timestamps
    end
  end
end
