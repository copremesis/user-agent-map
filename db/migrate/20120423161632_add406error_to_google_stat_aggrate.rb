class Add406errorToGoogleStatAggrate < ActiveRecord::Migration
  def up
    add_column :google_stat_aggregates, :_406_error, :integer
  end

  def down
    remove_column :google_stat_aggregates, :_406_error
  end
end
