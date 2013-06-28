class AddConnectionRestionToGoogleAggregateStat < ActiveRecord::Migration
  def change
    add_column :google_stat_aggregates, :_connection_reset, :integer
  end
end
