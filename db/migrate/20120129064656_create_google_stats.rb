class CreateGoogleStats < ActiveRecord::Migration
  def change
    create_table :google_stats do |t|
      t.string :url
      t.string :detail
      t.string :linked_from
      t.datetime :detected

      t.timestamps
    end
  end
end
