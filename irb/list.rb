

legacy = 'http://www.apartmenthomeliving.com'
ahl3 = 'http://ahl3rubys.apts.classifiedventures.com'

ap ->(old, new) {
  PropertyCompare.where("status like '%404%' and overview_url not like '%rental-home%'").map {|row|
    h = {}
    path = (row.dupe_url.size != 0)? row.dupe_url : row.overview_url
    path = (path.size == 0)?  PropertyCompare.find(row.property_id).overview_url : path
    h.update(:dotnet => [old, path].join)
    h.update(:rails => [new, path].join)
    h.update(:property_id => row.property_id)
    h
  }
}[legacy, ahl3]



# remove false positives
=begin
require 'open-uri'
PropertyCompare.where("status like '%404%'").each {|row|
  path = (row.dupe_url.size != 0)? row.dupe_url : row.overview_url
  path = (path.size == 0)?  PropertyCompare.find(row.property_id).overview_url : path
  url = [ahl3, path].join
  begin
    puts ['requesting', url].join(': ')
    open(url)
    row.update_attributes(:status => 200)
  rescue => e
    #leave as is
  end
}
=end


#[PropertyCompare.count - 25115, 1.0 - PropertyCompare.where(:status => nil).count.to_f/(PropertyCompare.count - 25115)]

#decent directory url

#http://www.apartmenthomeliving.com/apartment-finder/Waters-Edge-Georgetown-TX-78626-5019

#=begin

histo = {
  'properties_observed' => 0,
  'title' => 0, 
  'vcard' => 0, 
  'models_pricing' => 0,
  'amenities' => 0,
  'images' => 0, 
  'floorplans' => 0,
}
  

@title_updates = []
File.open('/tmp/4sterling.txt', 'w') {|fd|
  #PropertyCompare.where("phase2_score is not NULL and overview_url not like '%rental%'").each {|row|
  PropertyCompare.where("phase2_score is not NULL").order(:phase2_score).each {|row|
    #r = {row.property_id =>  JSON.parse(row.phase2_short_report) }
    r = JSON.parse(row.phase2_short_report)
    #ap r
    histo['properties_observed'] += 1 
    r.each {|k,v|
      begin
      histo[k]+=1 if v == 'fail'
      @title_updates << row.id if k == 'title' and v == 'fail'
      rescue => e
        puts [e, k].inspect
      end
    }
  #sleep 1
    fd.puts 'comparing..'
    fd.puts [ahl3, row.good_url].join
    fd.puts [legacy, row.good_url].join
    fd.puts JSON.pretty_generate( r )
  }
}

ap histo

ap x = {
  not_tested: PropertyCompare.where(:active => 1, :status => nil).count,
  exists: PropertyCompare.where(:active => 1, :status => 200).count,
  failure: PropertyCompare.where("active = 1 and status is not NULL and status != 200").count,
  failure_rhp: PropertyCompare.where("active = 1 and status is not NULL and status != 200 and overview_url like '%rental%'").count,
  failure_404: PropertyCompare.where("active = 1 and status is not NULL and status like '%40_%' and overview_url not like '%rental%'").count,
  failure_500: PropertyCompare.where("active = 1 and status is not NULL and status like '%50_%' and overview_url not like '%rental%'").count,
  active: PropertyCompare.where(:active => 1).count
}


#@title_updates
