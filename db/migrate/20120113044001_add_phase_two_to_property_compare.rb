class AddPhaseTwoToPropertyCompare < ActiveRecord::Migration
  def change
    add_column :property_compares, :phase2_score, :string
    add_column :property_compares, :phase2_short_report, :text
    add_column :property_compares, :phase2_long_report, :text
  end
end
