

scrape_dealer = ->(url) {
  puts ['opening', url].join(': ')
  title = url.split(/\//)[-1].gsub(/\.html/, '').gsub(/\-/, ' ')
  agent = Mechanize.new
  page = agent.get url 
  address = page.parser.xpath('//*[@id="cardetails"]/div[2]//p').to_a
  ([title.upcase] | address).join('|').gsub(/\|advertisements/i, '')
}

(1..1523).each {|i|
  puts "connecting to: http://www.dealershipslist.com/car-dealers/alpha/all/page/#{i}/"
  host = "http://www.dealershipslist.com"
  agent = Mechanize.new
  page = agent.get "http://www.dealershipslist.com/car-dealers/alpha/all/page/#{i}/"
  dealer_page = page.parser.xpath('//*[@id="col2_left"]//a').map { |anchor| anchor[:href] }.delete_if {|path| !!path.match(/(alpha|page)/) }
  File.open("/tmp/dealer_page#{i}", "w") {|fd|
    fd.puts dealer_page.map {|path| scrape_dealer.call([host, path].join) }.join("\n")
  }
}

