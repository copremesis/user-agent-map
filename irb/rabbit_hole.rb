require 'open-uri'

def single_threaded
  GoogleStats.select('url').where("detail like '%404%'").limit(20).map {|row|
    status = ->(url) {
      begin
        puts "attempting: #{row.url}"
        open(url)
        return 'okay'
      rescue => e
        return e.to_s
      end
    }[row.url]
    h = {:url => row.url, :status => status}
  }
end

def multi_threaded
  results, threads = [], []
  GoogleStats.select('url').where("detail like '%404%'").limit(20).each {|row|
    threads << Thread.new {
      status = ->(url) {
        begin
          #puts "attempting: #{row.url}"
          open(url)
          return 'okay'
        rescue => e
          return e.to_s
        end
      }[row.url]
      results <<  {:url => row.url, :open_uri_status => status}
    }
  }
  threads.map(&:join) #wait for threads to finish
  results
end

timer = ->(b) {
  t = Time.new
  res = b[]
  puts ['time of execution', Time.new - t].join(': ')
  res
}

#timer[->{single_threaded}]
#timer[->{multi_threaded}]

=begin
d = Dir.new('/tmp')
x = d.entries.grep(/Web.*\.json/).map {|file|
  z = JSON.parse(File.read('/tmp/'+file)).reduce({}) {|h,a|
    h.update(['_',a['detail'].downcase.gsub(/\s+|\-|\./, '_').gsub(/\(|\)/, '')].join.to_sym => a['number_found'].to_i)
  }.update(:date => Time.parse(file.split(/\./)[0].split(/_/)[-1]), :file => file)
  z
}
ap x
=end

#build model

=begin
@type_guesser = ->(field_name) {
  case field_name
  when /date|detected/i
    'datetime'
  when /from|detail|type|file/i
    'string'
  else
    'integer'
  end
}

cli_fields = x[0].keys.map {|e| [e, @type_guesser[e]].join(':') }.join(' ')
model_name = "google_stat_aggregate"
puts `rails generate model #{model_name} #{cli_fields} && rake db:migrate`
reload!
x.each {|row|
  model_name.camelize.constantize.create(row)
}
=end
ap GoogleStatAggregate.all.map {|row|
  h = {:'404s' => row._404_not_found,
       :'500s' => row._500_error,
       :'403s' => row._403_error,
       :date => row.date.strftime("%m/%d/%Y %H:%M:%S")
  }
}#.to_json#.offset(page * 20).limit(20).to_json
#nil
#require 'open-uri'
#!!open('http://minneapolis-st-paul.apartmenthomeliving.com/apartment-guide/minneapolis-minnesota').read.match(%r/Rose-Vista-Apartments-Roseville-MN-55113-209403/)
#
#require 'open-uri'
#!!open('http://www.apartmenthomeliving.com/apartment-finder/Veloce-Redmond-WA-98052-209016.mobi').read.match(%r/Veloce-Redmond-WA-98052-209016/)
#

=begin
require 'timeout'

retries = 42

begin
 Timeout::timeout(10){
   open('http://a.url.com') do |f|
     # ... stuff with f
   end
 }
rescue Timeout::Error
 retries -= 1
 if retry > 0
   sleep 0.42 and retry
 else
   raise
 end
end
=end


class String
  def recursive_reverse
    (self.size == 1)?  self : self[-1] + self[0...-1].recursive_reverse
  end
end

'ratsliveonnoevilstar'.recursive_reverse



#http://localhost:3000/apartment-finder/75SL-Arborpoint-Apartments-Medford-MA-02155-210703
#


=begin

require 'tempfile'

#_404_page = '/apartment-finder/75SL-Arborpoint-Apartments-Medford-MA-02155-210703'
_404_page = 'http://localhost:3000/apartment-finder/Trailside-Apartments-Hopkins-MN-55343-210526'
regex = %r~#{_404_page}~
#source = 'http://boston.apartmenthomeliving.com/apartment-guide/wakefield-massachusetts/apartments-for-rent/furnished.xls'
source = 'http://colorado-springs.apartmenthomeliving.com/apartment-guide/mountain-shadows-colorado-springs/apartments-for-rent.xls'
Tempfile.open('foo') {|f|
  `wget -O #{f.path} #{source}` #download xls file
  case source
  when /\.xls$/
     res = (`xls2csv #{f.path} | grep '#{_404_page}' | wc -l`.to_i == 1)
  when /\.pdf$/
     res = (`strings #{f.path} | grep '#{_404_page}' | wc -l`.to_i == 1)
  else
  end
}
=end
=begin
case source
when /\.xls$/
  Tempfile.open('xls') {|f|
    `wget -O #{f.path} #{source}` #download xls file
     res = (`xls2csv #{f.path} | grep '#{_404_page}' | wc -l`.to_i == 1)
  }
when /\.pdf$/
  Tempfile.open('pdf') {|f|
    `wget -o #{f.path} #{source}` #download pdf file
     res = (`xls2csv #{f.path} | grep '#{_404_page}' | wc -l`.to_i == 1)
  }
else
end
=end

def romfoo(roman)
  rom=n=0
  roman.bytes{
    |b|
    rom  +=b==77 ? n==100 ? n=800:  1000
    : b==67 ? n==10  ? n=80 : n=100
    : b==88 ? n==1   ? n=8  :  n=10
    : b==73 ? n=       n=       n=1
    : b==68 ? n==100 ? n=300:   500
    : b==76 ? n==10  ? n=30 :    50
    :         n==1   ? n=3  :     5
  }
  rom
end

roman2no = ->(roman) {
  r,compute,rom,o2,s = {I:1,V:5,X:10,L:50,C:100,D:500,M:1000}, ->(o2) { (o2[0] < o2[1].to_i)? -o2.shift + o2.shift : o2.shift },roman.chars.map{|e| r[e.to_sym] }+[0],[],0
  while rom.size > 0
    o2.push(rom.shift) while o2.size != 2
    s+=compute[o2]
  end
  {roman => s}
}

rand_rom = ->(n) {
  a = 'IVXLCDM'
  s = ''
  n.times {
    s << a[rand(a.size)]
  }
  s
}

Benchmark.bm { |x|
  x.report('rob') {
    rand(1<<64).to_s(base=16)
  }
  x.report('brandon') {
    rand(36**16).to_s(36)
  }
  x.report('roman') {
    roman2no['MCMXCIX']
  }
  x.report('roman2') {
    roman2no['MDCCCCLXXXXVIIII']
  }
  x.report('roman3') {
    romfoo('MDCCCCLXXXXVIIII')
  }

  x.report('obj system info') {
    Htop::Htop.obj_system_info
  }
}
#ap roman2no['MCMXCIX']
#ap roman2no['MDCCCCLXXXXVIIII']
ap roman2no[rand_rom[200]]
