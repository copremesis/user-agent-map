class CreateGoogleStatAggregates < ActiveRecord::Migration
  def change
    create_table :google_stat_aggregates do |t|
      t.integer :_400_error
      t.integer :_403_error
      t.integer :_404_not_found
      t.integer :_404_like_content
      t.integer :_500_error
      t.integer :_502_error
      t.integer :_503_error
      t.integer :_network_unreachable
      t.integer :_no_response
      t.integer :_redirect_error
      t.integer :_redirecting_to_error_page
      t.integer :_truncated_response
      t.integer :_url_restricted_by_robots_txt
      t.datetime :date
      t.string :file

      t.timestamps
    end
  end
end
