


#dupe_type,dupe_url,overview_url,property_id,listing,property_type,active,alt_property_id
#directory,,/apartment-finder/Cliffs-at-Barton-Creek-Austin-TX-78746-5005,5005,2,directory,1,0
#require 'ap'

#sqlite3_busy_timeout( db, 100 )


def good_or_bad(good, bad)
  begin
    good.call
  rescue => e
    bad.call(e)
  end
end

=begin
@bad_rows = []
def good_or_bad(good, bad)
  begin
    good.call
  rescue => err
    bad.call(err)
  end
end


first = true
File.open('url_data').readlines.each {|line|
  if (first)
   fields = line.split(/,/)
   first = false
  else
    good_or_bad(-> {
      l = line.chomp.split(/,/)
      newrow = fields.reduce({}) {|r, f| r.update(f.chomp.to_sym => l.shift) }
      PropertyCompare.create(newrow)
    }, -> {
      @bad_rows << line
    })
  end
}

ap @bad_rows
=end


=begin
File.open('/tmp/preliminary_tests', 'w') {|fd|
  urls = PropertyCompare.limit(1000).where(:active => 1).map {|row| (row.dupe_url.size > 0)? row.dupe_url : row.overview_url}
  urls.map { |url| ['http://ahl3rubys.apts.classifiedventures.com', url].join }.each {|ahl3_url|
    puts ['testing', ahl3_url].join(': ')
    good_or_bad(-> {
      res = open(ahl3_url)
      #fd.puts [ahl3_url, 'pass'].join(': ')
    }, ->(e) {
      fd.puts [ahl3_url, e].join(': ')
    })  
  }
}
=end

require 'open-uri'

File.open('/tmp/preliminary_tests', 'w') {|fd|
  #urls = PropertyCompare.limit(1000).where(:active => 1).map {|row| (row.dupe_url.size > 0)? row.dupe_url : row.overview_url}
  #urls.map { |url| ['http://ahl3rubys.apts.classifiedventures.com', url].join }.each {|ahl3_url|
  PropertyCompare.where("active = 1 and status is NULL").each { |row|
  #PropertyCompare.where("active=1 and status != '200' and overview_url like '%rental%'").each { |row|
    #ahl3_url = (row.dupe_url.size > 0)? row.dupe_url : row.overview_url
    ahl3_url = ['http://ahl3rubys.apts.classifiedventures.com', ahl3_url = (row.dupe_url.size > 0)? row.dupe_url : row.overview_url].join
    puts ['testing', ahl3_url].join(': ')
    good_or_bad(-> {
      res = open(ahl3_url)
      #fd.puts [ahl3_url, 'pass'].join(': ')
      row.update_attributes(:status => 200)
    }, ->(e) {
      #fd.puts [ahl3_url, e].join(': ')
      row.update_attributes(:status => e)
      sleep(1)
    })  
  }
}


