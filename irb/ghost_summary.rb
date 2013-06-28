  reload!
  load 'lib/cache_me/cache_me.rb'
  params = {:page=>"", :key=>"ghost_summary", :duration=>"month"}
  @time_unit = params[:duration] || 'day'
  @page = (params[:page] || 0).to_i 

  #CraigslistTemplateHits.ghost_summary(@time_unit, @page, params[:property_id])
  #CraigslistTemplateHits.template_hit_distribution(@time_unit, params[:property_id])
  #CraigslistTemplateHits.ghost_inquiry(@time_unit, params[:property_id])

  #CraigslistTemplateHits.where(:property_id => 394867).select("ip, referrer, log_stamp")



duration = 1.send(@time_unit).ago
range = (duration..Time.now.utc)

property_id = 845384

=begin
CraigslistTemplateHits.select("referrer, post_date as day, count(log_stamp) as number_of_posts_this_day")
                     .where(:property_id => property_id)
                     .where("referrer  like 'http%.craigslist.org/%.html'")
                     .where(:log_stamp => range)
                     .group(:day)
                     .order("number_of_posts_this_day DESC").reduce({}) { |h, row|
  
                    }
 
=end



=begin
->(pid) {
  histo = {}
  CraigslistTemplateHits.select("count(referrer) as hits, referrer, post_date, template, ip")
                        .where(:post_date => range)
                        .where(:property_id => property_id)
                        .where("referrer  like 'http%.craigslist.org/%.html'")
                        .group(:referrer)
                        .order("post_date desc").each {|row|
                          day = row.post_date.to_s[0,10]
                          histo[day] = histo[day] || 0
                          histo[day] += 1
                        }
  histo.map{|date, number_of_posts| {:date => date, :number_of_posts => number_of_posts}}
}[property_id].to_json
=end

#CacheMe::CacheMe.make_key([property_id, range])

#CraigslistTemplateHits.per_day(@time_unit, property_id)


#trace_route 


load 'lib/htop/htop.rb'


@ip2latlon = ->(ip) {
  @geo ||= GeoIP.new(Rails.root.join('GeoLiteCity.dat').to_s) #try caching this object?
  r = @geo.city(ip)
  (r)? [r.latitude , r.longitude]: [0.0, 0.0]
}

def traceroute(ip) 
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
  (route[2,route.size] + [route[0]]).map {|ip|
    @ip2latlon[ip]
  }
end

#traceroute('190.7.201.170')
#traceroute('114.32.190.83')


timer = ->(b) {
  t = Time.new
  res = b[]
  puts ['time of execution', Time.new - t].join(': ')
  res
}

ips = ["115.32.190.83", "189.38.47.172", "190.7.201.170", "203.186.89.166", "212.179.90.60", "46.39.16.42", "50.115.169.159", "91.205.189.15", "95.163.100.31", "116.255.142.180", "60.12.251.5", "93.75.188.54"]
ips.map {|ip|
  timer[->(){
    puts CacheMe::CacheMe.make_key([ip, 'traceroute'])
    traceroute(ip)
  }]
}

transponder = {
  property_id: 394867,
  template: 1.1,
  post_stamp: Time.now.to_i,
  filename: 'Hallidayprop.jpg'
}
"https://mymedia.apartments.com/imgs/public/mmcl-#{transponder[:property_id]}-#{transponder[:template]}-#{transponder[:post_stamp]}.#{transponder[:filename]}"


uri = 'http://localhost:4444/main/json_data?page=8&key=clicks&filter=ghost_inquiry&property_id=19267&duration=month'
url, query = uri.split(/\?/)
params = query.split(/&/).reduce({}) {|h, pair| k,v = pair.split(/=/); h.update(k.to_sym => v)}
ap params
Digest::MD5.hexdigest(params.to_s)
