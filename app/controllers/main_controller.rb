class MainController < ApplicationController
  def foo
    #render :text => '<script> alert("hi"); </script>'
    render :text => '<a href=''> click me </a>'
  end

  def index
    #Rails.logger.info(params.inspect)
    #@duration = 1.send(params[:duration] || 'year').ago rescue 1.year.ago
    #Rails.logger.info(@duration.to_s)
  end

  def json_data
    @duration = 1.send(params[:duration] || 'day').ago rescue 1.day.ago
    @range = (@duration..Time.now.utc)
    json = case(params[:key])
           when /bing/
             BingStats.select("count(*) as number_found, http_code").group(:response_type).to_json
           when /linked_from/
             GoogleSourceStats.linked_from(params)
           when /google_stats/
             GoogleStatAggregate.historical(params)
           when /google/
             GoogleStats.summary
           when /clicks/
             case(params[:filter])
             when /ghost_inquiry/#match parent event
               CraigslistTemplateHits.ghost_inquiry(params[:duration] || 'day', params[:property_id])
             when /per_day/
               CraigslistTemplateHits.per_day(params[:duration] || 'day', params[:property_id])
             else
               GoogleStats.google_verify(params)
             end
           when /hits/
             mapthis = ->(e) { "<div class=click event='geolocate' ip='#{e}'>#{e}</div>" }
             CraigslistTemplateHits.select("log_stamp, ip, user_agent")
                                   .where(:log_stamp => @range)
                                   .where(:property_id => params[:property_id], :referrer => params[:filter])
                                   .order(:log_stamp).map {|row|
                                     row = {
                                       :clicked_on => row.log_stamp.to_s,
                                       :ip_address => mapthis[row.ip],
                                       :user_agent => row.user_agent
                                     }
                                   }.to_json
           when /gantt/
             Gantt.all.to_json
           when /png/ #screen capture from the canvas tag ... we can store it in the file system to create movies 
             #Rails.logger.info(params[:data])
             File.open('/tmp/blah', 'w') {|fd| fd.puts(params[:data]) }
             {:png_captured => true}.to_json
           when /ghost_summary/
             time_unit = params[:duration] || 'day'
             page = (params[:page] || 0).to_i
             CraigslistTemplateHits.ghost_summary(time_unit, page, params[:property_id])
           when /hyperV/
             #File.read('/tmp/all.json')
            "jQuery('" + JSON.parse(File.read('/tmp/all.json')).map {|point|
              foo = point['total']
              d = Time.parse(foo['date'])
              "[Date.UTC(#{d.year},#{d.month - 1},#{d.day}),#{foo['value']}]"
            }.inspect.gsub(/\"/, '') + ');'
           when /template_hit_distribution/
             CraigslistTemplateHits.template_hit_distribution(params[:duration] || 'day', params[:property_id])
           else
             #WorldClock::WorldClock.times.to_json
             Htop::Htop.obj_system_info.to_json
           end
    render :text => json
  end

  def test_url
    render :text => ->(url) {
      Timeout::timeout(5) {
        agent = Mechanize.new
        nested_page = agent.get(url).frames[0].href rescue url
        agent.get(nested_page)
        'online'
      } rescue 'offline'
    }[params[:url]]
  end

  def geolocate
=begin
    ip2latlon = ->(ip = '216.54.231.78') {
      a = Mechanize.new
      p = a.get("http://www.geobytes.com/IpLocator.htm?GetLocation&IpAddress=#{ip}")
      [p.parser.xpath('/html/body/table[2]/tr/td[3]/table/tr/td/form/table/tr[6]/td[2]/input').attribute('value').value,
       p.parser.xpath('/html/body/table[2]/tr/td[3]/table/tr/td/form/table/tr[6]/td[4]/input').attribute('value').value]
    }
=end
    @ip2latlon = ->(ip) {
      @geo ||= GeoIP.new(Rails.root.join('GeoLiteCity.dat').to_s) #try caching this object?
      r = @geo.city(ip)
      [r.latitude, r.longitude]
    }
    ip = params[:ip] #do some validation here plz
=begin
    geocache = Ipcache.find_or_create_by_ip(ip)
    lat, lon = nil, nil
    if (geocache.lat == nil && geocache.lon == nil)
      lat, lon = ip2latlon[ip]
      geocache.update_attributes(:lat => lat, :lon => lon)
    end
    render :text => [geocache.lat, geocache.lon].to_json
=end
    lat, lon = @ip2latlon[ip]
    render :text => [lat, lon].to_json
  end

  def traceroute
    @ip2latlon = ->(ip) {
      @geo ||= GeoIP.new(Rails.root.join('GeoLiteCity.dat').to_s) #try caching this object?
      r = @geo.city(ip)
      [r.latitude, r.longitude]
    }
    ip = params[:ip]
    payload = CacheMe::CacheMe.memcache_bypass(ip, 'traceroute') {
      #host, user, pass some linux box with traceroute installed
      Htop::SSHRPC.new.rr("bash", HOST, :username => USER, :password => PASS, :timeout => 300) { |ssh|
        ssh.send_data("traceroute #{ip}\n")
        ssh.send_data("exit\n")
      }
    }
    route = payload.split(/\n/)
                 .grep(/\(.*\)/)
                 .map {|hop|
                   hop.gsub(/^[^(]+\(/, '').gsub(/\).*$/, '')
                 }
    coords = (route[2,route.size] + [route[0]]).map {|ip|
      @ip2latlon[ip]
    }
    render :text => coords.to_json
  end
  
end

