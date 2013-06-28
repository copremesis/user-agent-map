class GoogleStats < ActiveRecord::Base
  include Extensions

  def self.summary
    self.select("count(*) as number_found, detail").group(:detail).map {|row|
      click = ->(e) { "<div class=click event='#{e}'>#{e}</div>" }
      h = {:number_found => row.number_found, :detail => click[row.detail]}
    }.to_json
  end

  def self.google_verify(args)
    results, threads = [], []
    get_path = ->(url, host='') {url.gsub(/http:.*?com/, '')}
    change_to_local = ->(url, host='http://localhost:3000') {url.gsub(/http:.*?com/, host)}

    link = ->(e) { "<a target='_blank' href='#{change_to_local[e]}'> #{get_path[e]} </a>" }
    detail = CGI::unescape(args[:filter] || '404 (Not found)') #perhaps a hash table to avoid sql-injection?
    page = (args[:page] || 0).to_i
    self.select(%{detected, url , linked_from, detail}).where(:detail => detail).offset(page * 20).limit(20).each {|row|
      threads << Thread.new {
        status = ->(url) {
          begin
            #puts "attempting: #{row.url}"
            open(url)
            return 'okay'
          rescue => e
            return e.to_s
          end
        }[change_to_local[row.url, 'http://www.apartmenthomeliving.com']]
        #}[change_to_local[row.url]]
        #results <<  {:url => link[row.url], :open_uri_result => status}.update(:detected => row.detected.strftime("%m/%d/%Y"), :linked_from => row.linked_from, :detail => row.detail)
        #
        click = ->(e) { (e == 'unavailable')? e : "<div class=click event='linked_from' url='#{row.url}'>#{e}</div>" }
        results <<  {
          :url => link[row.url],
          :open_uri_result => status,
          :detected => row.detected.strftime("%m/%d/%Y"),
          :linked_from => click[row.linked_from],   #GoogleSourceStats.select("count(*) as linked_from").where(:url => row.url).first.linked_from,
          :detail => row.detail
        }
      }
    }
    threads.map(&:join)
    results.to_json
  end

  private
  #legacy code until I relized I can use the multi threading to reexamine the links provided in the list
  def self.google_click(args)
    get_path = ->(url, host='') {url.split(/\//)[-1]}
      #switch host: run tests on your local!!!
      #gsub(ahl,your_local)

    link = ->(e) { "<a target='_blank' href='#{e}'> #{'/' + get_path[e]} </a>" }
    page = (args[:page] || 0).to_i
    detail = CGI::unescape(args[:filter] || '404 (Not found)') #perhaps a hash table to avoid sql-injection?
    GoogleStats.select(%{detected, url , linked_from, detail}).where(:detail => detail).offset(page * 20).limit(20).map {|row|
      h = {}
      h.update(:detected => row.detected.strftime("%m/%d/%Y"), :url => link[row.url], :linked_from => row.linked_from, :detail => row.detail)
    }.to_json
  end
end
