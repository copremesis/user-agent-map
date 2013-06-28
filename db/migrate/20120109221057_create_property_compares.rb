class CreatePropertyCompares < ActiveRecord::Migration
  def change
    create_table :property_compares do |t|
      t.string :dupe_type
      t.string :dupe_url
      t.string :overview_url
      t.integer :property_id
      t.integer :listing
      t.string :property_type
      t.integer :active
      t.integer :alt_property_id
      t.string :status
      t.timestamps
    end
  end
end
