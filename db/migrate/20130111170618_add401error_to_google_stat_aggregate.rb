class Add401errorToGoogleStatAggregate < ActiveRecord::Migration
  def up
    add_column :google_stat_aggregates, :_401_error, :integer
  end

  def down
    remove_column :google_stat_aggregates, :_401_error
  end
end
