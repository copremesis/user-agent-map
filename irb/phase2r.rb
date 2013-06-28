
reload!

def try_or_skip()
  begin
    return yield
  rescue => e
    puts [e, 'skipping ...'].join(':')
  end
end

def models_pricing(doc)
  #puts ['loading', url].join(': ')
  #doc = Nokogiri::HTML(open(url))
  models_pricing = doc.xpath('//table')
  models_pricing.xpath('//td').map {|table_data| 
    table_data.text.strip
  }.reject {|x| x.match(/check/) || x.match(/^\d$/) }.sort
end

def amenities(doc, range)
  #puts ['loading', url].join(': ')
  #doc = Nokogiri::HTML(open(url))
  amen = doc.xpath('//ul')[range]
  #puts amen.to_s
  amen.to_s.split(/\n/).reject {|x| x.match(/ul/)}.map {|e| e.gsub(/<[^>]*>/, '').strip }.reject {|x| x.match(/policy/) ||x.size ==0 }.sort
end

def title(doc1, doc2)
  puts 'checking title...'
  try_or_skip {
    @report[:title] = {
      :result => (doc1.xpath('//h1/span')[0].text.strip == doc2.xpath('//h1/span')[0].text.strip)? 'pass': 'fail',
      :scraped => {
        :ahl3 => doc1.xpath('//h1/span')[0].text, 
        :prod => doc2.xpath('//h1/span')[0].text
      }
    }
  }
end

def vcard(doc)
  try_or_skip {
    dl = doc.xpath('//dl')
    keys = dl.xpath('//dt').map {|k| k.text.strip}
    values = dl.xpath('//dd')
    keys.reduce({}) {|h,k|
      h.update(k => values.shift.text.strip)
    }
  }
end

def addresses_match(address1, address2)
  state_code_map = {"Alaska"=>"AK", "Alabama"=>"AL", "Arkansas"=>"AR", "American Samoa"=>"AS", "Arizona"=>"AZ", "California"=>"CA", "Colorado"=>"CO", "Connecticut"=>"CT", "District of Columbia"=>"DC", "Delaware"=>"DE", "Florida"=>"FL", "Federated States of Micronesia"=>"FM", "Georgia"=>"GA", "Guam"=>"GU", "Hawaii"=>"HI", "Iowa"=>"IA", "Idaho"=>"ID", "Illinois"=>"IL", "Indiana"=>"IN", "Kansas"=>"KS", "Kentucky"=>"KY", "Louisiana"=>"LA", "Massachusetts"=>"MA", "Maryland"=>"MD", "Maine"=>"ME", "Marshall Islands"=>"MH", "Michigan"=>"MI", "Minnesota"=>"MN", "Missouri"=>"MO", "Northern Mariana Islands"=>"MP", "Mississippi"=>"MS", "Montana"=>"MT", "North Carolina"=>"NC", "North Dakota"=>"ND", "Nebraska"=>"NE", "New Hampshire"=>"NH", "New Jersey"=>"NJ", "New Mexico"=>"NM", "Nevada"=>"NV", "New York"=>"NY", "Ohio"=>"OH", "Oklahoma"=>"OK", "Oregon"=>"OR", "Pennsylvania"=>"PA", "Puerto Rico"=>"PR", "Palau"=>"PW", "Rhode Island"=>"RI", "South Carolina"=>"SC", "South Dakota"=>"SD", "Tennessee"=>"TN", "Texas"=>"TX", "Utah"=>"UT", "Virginia"=>"VA", "Virgin Islands"=>"VI", "Vermont"=>"VT", "Washington"=>"WA", "Wisconsin"=>"WI", "West Virginia"=>"WV", "Wyoming"=>"WY"} 
  
  a1 = address1.split(/\s/)
  a2 = address2.split(/\s/)
  a1.reduce(true) {|flag, e|
    if state_code_map.keys.include?(e)
      flag | (a2[a1.index(e)] == state_code_map[e])
    else
      flag | e == a2[a1.index(e)]
    end
    flag
  }
end

def vcard_compare(v1, v2) 
  puts 'checking vcard..'
  try_or_skip {
    @report[:vcard] = {
      :result => addresses_match(v1['map us:'].split(/[ ,\n]+/).join(' '), v2['map us:'].split(/[ ,\n]+/).join(' '))? 'pass' : 'fail',
      :scraped => {
        :ahl3 => v2,
        :prod => v1,
      }
    }
  }
end

def compare(arr1, arr2)
  if(arr1 == arr2)
    puts 'pass'
  else
    puts 'fail'
  end
end

def fuzzy_compare(arr1, arr2)
  subset_test = (arr2 | arr1 == arr2)? :is_subset : [:missing, arr1 - arr2]
  symdiff = arr1 - arr2 | arr2 - arr1 
  [symdiff.size, subset_test, symdiff]
end


def images(pid)
  try_or_skip {
    puts 'testing images ...'
    ijson = JSON.parse(open("http://ahl3rubys.apts.classifiedventures.com/api/media/#{pid}.json").read)
    ahl3_images = ijson['media'].map {|img_data| img_data['asset']['full_location'].downcase.sub(/32\.jpg/, '64.jpg') }.sort
    doc = Nokogiri::HTML(open("http://www.apartmenthomeliving.com/apartment_finder/CommunityVideos.aspx?property_id=#{pid}").read)
    prod_images = doc.xpath('//img').map {|tag| tag['src'] }.grep(/\.jpg$/i).sort
    @report[:images] = {
      :result => (ahl3_images == prod_images)? 'pass': 'fail',
      :scraped => {
        :ahl3 => ijson['media'].map {|img_data| img_data['asset']['full_location']}.sort,
        :prod => prod_images
      },
      :fuzzy_compare => fuzzy_compare(ahl3_images, prod_images)
    }
  }
end

def floorplans(pid)
  try_or_skip {
    puts 'testing floorplans ...'
    fjson = JSON.parse(open("http://ahl3rubys.apts.classifiedventures.com/api/floorplans/#{pid}.json").read)
    ahl3_fps = fjson['media'].map {|img_data| img_data['asset']['full_location'].downcase.sub(/32\.jpg/, '64.jpg') }.sort
    doc = Nokogiri::HTML(open("http://www.apartmenthomeliving.com/apartment_finder/CommunityFloor.aspx?property_id=#{pid}").read)
    prod_fps = doc.xpath('//img').map {|tag| tag['src'] }.grep(/jpg/i).sort 
    @report[:floorplans] = {
      :result => (ahl3_fps == prod_fps)? 'pass': 'fail',
      :scraped => {
        :ahl3 => fjson['media'].map {|img_data| img_data['asset']['full_location']}.sort,
        :prod => prod_fps
      },
      :fuzzy_compare => fuzzy_compare(ahl3_fps, prod_fps)
    }
  }
end

require 'open-uri'

@report = {}

->(rails, dotnet, options = {}) {
  #PropertyCompare.where("property_type like '%premium%' and status = '200' and phase2_score is NULL").each { |row|
   #PropertyCompare.where("property_id = 179635").each {|row|
   #PropertyCompare.where("property_id = 179656").each {|row|
   #PropertyCompare.where("property_id = 189285").each {|row|
   #PropertyCompare.where("property_id = 179639").each {|row|
   PropertyCompare.where("property_id = #{options[:property_id]}").each {|row|

#PropertyCompare.where(:phase2_score => 16).each {|row|
   begin
      @report_res = {}
      u1 = [rails, row.good_url].join
      puts ['loading', u1].join(': ')
      ahl3_doc = Nokogiri::HTML(open(u1))

      u2 = [dotnet, row.good_url, '?foo=1'].join
      puts ['loading', u2].join(': ')
      prod_doc = Nokogiri::HTML(open(u2))
      [ahl3_doc, prod_doc]
    rescue => e
      puts [e, 'skipping...'].join(':')
      next
    end
    #title

    title(ahl3_doc, prod_doc)
    #note prod goes first for this one
    cmp = [vcard(prod_doc), vcard(ahl3_doc)]
    vcard_compare(cmp[0], cmp[1])
    #compare(cmp[0], cmp[1])
    #models/pricing
    cmp = [models_pricing(ahl3_doc), models_pricing(prod_doc)]
    #compare(cmp[0], cmp[1])
    @report[:models_pricing] = {
      :result => (cmp[0] == cmp[1])? 'pass': 'fail',
      :scraped => {
        :ahl3 => cmp[0],
        :prod => cmp[1]
      },
      :fuzzy_compare => fuzzy_compare(cmp[0], cmp[1])
    }
    #amenities
    cmp = [amenities(ahl3_doc, 2..5), amenities(prod_doc, 3..6)]
    @report[:amenities] = {
      :result => (cmp[0] == cmp[1])? 'pass': 'fail',
      :scraped => {
        :ahl3 => cmp[0],
        :prod => cmp[1]
      },
      :fuzzy_compare => fuzzy_compare(cmp[0], cmp[1])
    }
    #images
    images(row.property_id)
    #floorplans
    floorplans(row.property_id)

    ap @report #long_report
    try_or_skip {
      q = { 
        :title => @report[:title][:result],
        :vcard => @report[:vcard][:result],
        :models_pricing => @report[:models_pricing][:result],
        :amenities => @report[:amenities][:result],
        :images => @report[:images][:result],
        :floorplans => @report[:floorplans][:result],
      }
      ap q
      score =  (q.values.grep(/pass/).size.to_f/6 * 100).to_i
      ap score
      #row.update_attributes(:phase2_score => score, :phase2_short_report => q.to_json, :phase2_long_report => @report.to_json)
    }
  }
}['http://ahl3rubys.apts.classifiedventures.com','http://www.egustafson.ahl', :property_id => 179631]
nil
