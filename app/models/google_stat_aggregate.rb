class GoogleStatAggregate < ActiveRecord::Base
  def self.historical(args)
    page = (args[:page] || 0).to_i
    self.all.map {|row|
     h = {:'404s' => row._404_not_found,
          :'500s' => row._500_error,
          :'502s' => row._502_error,
          :'503s' => row._503_error,
          :'403s' => row._403_error,
          :'400s' => row._400_error,
          :'404ish' => row._404_like_content,
     #     :'no_response' => row._no_response,
          :'redirect_err' => row._redirect_error,
          :'redirect_to_err' => row._redirecting_to_error_page,
          #:'truncated_response' => row._truncated_response,
          :'restricted' => row._url_restricted_by_robots_txt,
          :date => row.date.strftime("%m/%d/%Y %H:%M:%S")
     }
    }.to_json
  end
end
