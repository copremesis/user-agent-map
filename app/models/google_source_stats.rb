class GoogleSourceStats < ActiveRecord::Base
  include Extensions
  def self.linked_from(args)
      results, threads = [], []
      get_path = ->(url, host='') {url.gsub(/http:.*?com/, '')}
      change_to_local = ->(url, host='http://localhost:3000') {url.gsub(/http:.*?com/, host)}
      link = ->(e) { "<a target='_blank' href='#{e}'> #{e} </a>" }
      url = CGI::unescape(args[:filter])
      self.select('linked_from, count(*) as repeats, discovery_date').where(:url => url).group(:linked_from).each {|row|
        threads << Thread.new {
          #confirmed is true/false or broken link
          confirmed = ->(linked_from, url) {
            begin
              Timeout::timeout(10) { #maxium of 10s lag
                res = open(linked_from)
                return !!res.read.match(%r/#{get_path[url]}/)
              }
              raise 'timeout 10s'
            rescue => e
              return e.to_s
            end
          }[row.linked_from, url]
          results << {
            :linked_from => link[row.linked_from],
            :repeats => row.repeats,
            :discovered => row.discovery_date.strftime("%m/%d/%Y %H:%M:%S"),
            :confirmed => confirmed
          }
        }
     }
     threads.map(&:join)
     results.to_json
  end
end
