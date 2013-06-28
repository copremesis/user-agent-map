class AddIndexToCraigslistTemplateHits < ActiveRecord::Migration
  def change
    add_index :craigslist_template_hits, :log_stamp
  end
end
