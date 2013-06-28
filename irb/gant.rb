
load 'lib/cache_me/cache_me.rb'


#x = JSON.parse('{"gantt":{"Apartments Feed":[{"duration":5505.780000209808,"start_time":"2012-03-01T21:36:48-06:00"}],"RentalHomesPlus Feed":[{"duration":882.9540002346039,"start_time":"2012-03-01T21:51:32-06:00"}],"Backup AHL":[{"duration":1472.7340002059937,"start_time":"2012-03-01T22:24:33-06:00"}],"Defrag AHL":[{"duration":2457.359999895096,"start_time":"2012-03-02T06:10:57-06:00"}],"My New Place Feed":[{"duration":3923.2799999713898,"start_time":"2012-03-01T23:35:24-06:00"}]},"xtics":["Thu 11:28a","Thu 01:52p","Thu 04:16p","Thu 06:40p","Thu 09:04p","Thu 11:28p","Fri 01:52a","Fri 04:16a","Fri 06:40a","Fri 09:04a","Fri 11:28a"],"hours":["2012-03-01T11:00:00-06:00","2012-03-01T12:00:00-06:00","2012-03-01T13:00:00-06:00","2012-03-01T14:00:00-06:00","2012-03-01T15:00:00-06:00","2012-03-01T16:00:00-06:00","2012-03-01T17:00:00-06:00","2012-03-01T18:00:00-06:00","2012-03-01T19:00:00-06:00","2012-03-01T20:00:00-06:00","2012-03-01T21:00:00-06:00","2012-03-01T22:00:00-06:00","2012-03-01T23:00:00-06:00","2012-03-02T00:00:00-06:00","2012-03-02T01:00:00-06:00","2012-03-02T02:00:00-06:00","2012-03-02T03:00:00-06:00","2012-03-02T04:00:00-06:00","2012-03-02T05:00:00-06:00","2012-03-02T06:00:00-06:00","2012-03-02T07:00:00-06:00","2012-03-02T08:00:00-06:00","2012-03-02T09:00:00-06:00","2012-03-02T10:00:00-06:00"],"size":6}')

#ap x
#
#


class Gantt
  @@defaults = {
    :starttime => 1.hour.ago,
    :endtime => 4.days.from_now
  }
  def self.generate_xlabels(opts={})
    # init the time variables if running in the console
    endtime = (opts[:endtime] || @@defaults[:endtime])
    starttime = (opts[:starttime] || @@defaults[:starttime])
    ticks = (opts[:ticks] || 10)
    # divide the duration into `ticks` equal parts
    step = (endtime - starttime).to_f / ticks.to_f
    # init the first item and loop the rest
    thisTime = starttime
    thisMin = ((thisTime.strftime("%M").to_f / 5.0).ceil * 5).to_s
    thisMin = "0#{thisMin}"  unless thisMin.size > 1
    rOut = [thisTime.strftime("%a %I:%M") + thisTime.strftime("%p").first.downcase]
    ticks.times{
      thisTime += (step / 60.0).minutes
      thisLbl = thisTime.strftime("%a %I:%M")
      rOut << thisLbl + thisTime.strftime("%p").first.downcase
    }
    # return the array
    return rOut
  end

  def self.hours_between
    t1 = @@defaults[:starttime]
    t2 = @@defaults[:endtime]
    hours = []
    k = 0
    t1 = Time.local(t1.year, t1.month, t1.day, t1.hour) #remove minutes to make condition terminate correctly
    t2 = Time.local(t2.year, t2.month, t2.day, t2.hour)
    d = t1
    while(d != t2 && k <= 1000) #fix your condition to round minutes down to the hour for this to be a valid loop terminator
      hours << d
      d += 1.hour
      k+=1
    end
    hours.map {|h| Time.local(h.year, h.month, h.day, h.hour)}
  end

  def self.build_gantt_data()
    yield
  end

  def self.all
    gantt = self.build_gantt_data() {
      a = Htop::Htop.obj_system_info
      #the strange array syntax is there may be more than one instance different use case
      a.reduce({}) {|h, row| h.update(row[:server] => [{'duration' => 3600, :start_time => row[:time]}]) }
    }
    chart_data = {
      :gantt => gantt,
      :xtics => self.generate_xlabels,#(:starttime => start_time, :endtime => end_time, :ticks => 10),
      :hours => hours_between,#(start_time, end_time),
      :size => gantt.keys.size + 1
    }
  end

end

#stdev = 100
#a = (0..10).map {
#  (Time.new + ((rand(2)==0)? stdev : -stdev))
#}
#a
#

=begin

f = Htop::SSHRPC.new
puts f.rr("bash", "apdf2.apts.classifiedventures.com", :username => 'user', :password => 'password') { |channel|
  channel.send_data("export TERM=screen && htop\n")
  channel.send_data("q")
  channel.send_data("df -h\n")
  channel.send_data("echo 'time:'$(date)\n")
  channel.send_data("exit\n")
}

=end

=begin
load 'lib/htop/htop.rb'
f = Htop::SSHRPC.new
ap f.hr
nil
=end

require 'open-uri'
url = 'http://www.apartmenthomeliving.com/apartment-guide/mineola-new-york/apartments-for-rent/from-700-to-1500/pet_friendly'


require 'ap'
require 'open-uri'

def multi_threaded_spike(url = 'http://www.apartmenthomeliving.com/apartment-finder/Lakes-at-Renaissance-Park-Austin-TX-78728-198248', n=5000)
  results , threads = {}, []
  results[url] = 0
  n.times {
    threads << Thread.new {
      status = ->(url) {
        begin
          puts 'loading ...'
          sleep(rand())
          open(url)
          return 'okay'
        rescue => e
          return e.to_s
        end
      }[url]
      #results <<  {:url => url, :open_uri_status => status}
      results[url] += (status != 'okay')? 1 : 0
    }
  }
  threads.map(&:join) #wait for threads to finish
  results
end

#ap multi_threaded_spike(url, 20)


#CraigslistTemplateHits(id: integer, guid: string, property_id: integer, ip: string, log_stamp: datetime, post_date: datetime, referrer: string, template: string, user_agent: string, created_at: datetime, updated_at: datetime) 

=begin
JSON.parse(File.read('/tmp/craigs_list_test_data.json')).each {|row|
  CraigslistTemplateHits.create(row['craigslist_template_hits'].select {|k,v| %w(guid property_id ip log_stamp post_date referrer template user_agent).include?(k) })
}
=end
#there is some API for AHL
#CraigslistTemplateHits.select("property_id, count(*) as ads").group(:property_id).order("ads desc").offset(0).limit(10)
#CraigslistTemplateHits.select("count(referrer) as hits, referrer").where(:property_id => 828745).group(:referrer)
#CraigslistTemplateHits.select("log_stamp, ip, user_agent").where(:property_id => 828745, :referrer => 'http://orlando.craigslist.org/apa/2912116185.html').order(:log_stamp)


#CraigslistTemplateHits.select("count(distinct referrer) as ads, property_id").group(:property_id).offset(0).limit(10)
#
#require 'open-uri'
#x = open('http://google.com').read rescue 'offline'
#x = open('http://dragonwrench.com/permalink?key=765b2af764bb06fb5d1c81dfbb9878f0').read rescue 'offline'
#x = open('http://70.253.88.30:3000/permalink?key=765b2af764bb06fb5d1c81dfbb9878f0').read rescue 'offline'
#recursive?
#
#open('http://dragonwrench.com/permalink?key=765b2af764bb06fb5d1c81dfbb9878f0') {|res|
=begin
x = open('http://dragonwrench.com/permalink?key=765b2af764bb06fb5d1c81dfbb9878f0') { |res|
  html = res.read
  puts CGI::pretty(res.read)
} rescue 'offline'
=end

=begin
test_url = ->(url) {
  Timeout::timeout(5) {
    @agent = Mechanize.new
    nested_page = @agent.get(url).frames[0].href rescue url
    @agent.get(nested_page)
    'online'
  } rescue 'offline'
}

#test_url['http://google.com']
test_url['http://dragonwrench.com/permalink?key=765b2af764bb06fb5d1c81dfbb9878f0']

a = %w( y p o v a i s n) #.permutations
=end

=begin
def ip2latlon(ip = '70.253.88.30')
  a = Mechanize.new
  @p = a.get('http://www.iplocation.net/index.php')
  form = @p.forms[2]
  form.query(ip)
  @p = a.submit form
  [@p.parser.xpath('/html/body/div/table[4]/tr/td/table/tr/td/table/tr[2]/td/div/table/tr/td/table[2]/tr[8]/td[3]').text.to_f,
         @p.parser.xpath('/html/body/div/table[4]/tr/td/table/tr/td/table/tr[2]/td/div/table/tr/td/table[2]/tr[8]/td[4]').text.to_f]
end


@n = CraigslistTemplateHits.count
@offset = 0
@limit = rand(100)
while (@offset + @limit < @n) do
  CraigslistTemplateHits.select("distinct ip").offset(@offset).limit(@limit).each {|row|
    geocache = Ipcache.find_or_create_by_ip(row.ip)
    lat, lon = nil, nil
    if (geocache.lat == nil && geocache.lon == nil)
      begin
        lat, lon = ip2latlon(row.ip)
      rescue => e
        puts [e, 'slowwing down scraping API']
        sleep(3)
      end
      geocache.update_attributes(:lat => lat, :lon => lon)
    end
    #check cache for existence of points before executing the api request
  }
  @offset += @limit
  @limit = rand(100)
  puts ['offset', @offset].join(': ')
  puts ['limit', @limit].join(': ')
  sleep(1)
end

=end
#slow as crap
def update_hits
  reload!
  JSON.parse(File.read('/tmp/craigs_list_test_data.json')).each {|row|
    CraigslistTemplateHits.create(row['craigslist_template_hits'].select {|k,v| %w(guid property_id ip log_stamp post_date referrer template user_agent).include?(k) })
  }
end

#update_hits

#super fast
def faster_update_hits
  reload!
  first = true
  header = []
  rows = JSON.parse(File.read('/tmp/craigs_list_test_data.json')).map {|row|
    if first
      header = row['craigslist_template_hits'].keys
      first = false
    end
    row['craigslist_template_hits'].values
  }

  #ap header
  #ap rows[0,5]
  CraigslistTemplateHits.import(header, rows)
end

faster_update_hits


=begin
JSON.parse(File.read('/tmp/all.json')).map {|point|
  foo = point['total']
  d = Time.parse(foo['date'])
  "[Date.UTC(#{d.year},#{d.month},#{d.day}),#{foo['value']}]"
}.to_json

=end
