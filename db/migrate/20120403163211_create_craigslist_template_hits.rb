class CreateCraigslistTemplateHits < ActiveRecord::Migration
  def change
    create_table :craigslist_template_hits do |t|
      t.string :guid
      t.integer :property_id
      t.string :ip
      t.datetime :log_stamp
      t.datetime :post_date
      t.string :referrer
      t.string :template
      t.string :user_agent

      t.timestamps
    end
  end
end
