

#row = GoogleSourceStats.first
require 'open-uri'
require 'timeout'

#only 250K urls to scan yet this will give us the info we want on where to fix urls on our site that point to
#404s on the site ..
#then based on the frequency of discoveries can make desicions on particular code areas where this is common
#like: .mobi (facebook) .atom ...
GoogleSourceStats.where(:confirmed => nil).each {|row|
  begin
    Timeout::timeout(10) {
      row.update_attributes(:confirmed =>  !!open(row.linked_from).read.match(%r~#{row.url}~))
    }
  rescue => e
    puts e
    reload!
    row.update_attributes(:confirmed => false)
  end
}
