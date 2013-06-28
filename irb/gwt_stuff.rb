
reload!


#ruby-1.9.2-p180 :003 > GwtErrors
# => GwtErrors(id: integer, url: string, linked_from: string, discovery_date: date, created_at: datetime, updated_at: datetime)


@ignore = ->(f, msg = ''){
  begin
    return f[]
  rescue => e
    puts [e, msg].join(': ')
    foo = gets
  end
}

@type_guesser = ->(field_name) {
  case field_name
  when /date|detected/i
    'datetime'
  when /from|url|detail|type/i  
    'string'
  else
    'integer'
  end
}

#file = 'Web_crawl_errors_www_apartmenthomeliving_com_20120201T214648Z.csv'
def update_aggregates(file)
  z = GoogleStats.select("count(*) as number_found, detail").group(:detail).reduce({}) {|h,a|
    h.update(['_',a['detail'].downcase.gsub(/\s+|\-|\./, '_').gsub(/\(|\)/, '')].join.to_sym => a['number_found'].to_i)
  }.update(:date => Time.parse(file.split(/\./)[0].split(/_/)[-1]), :file => file)
  GoogleStatAggregate.create(z)
end

def import_csv(model_name, file, options = {})
  first = true
  fields = nil
  require 'csv'
  CSV.parse(File.read(file)).each {|row|
    if first
      first = false
      cli_fields = row.map {|e| [e.strip.gsub(/[\u0080-\u00ff]/, '').gsub(/\r\n/m, '').gsub(/\s/, '_').downcase, @type_guesser[e]].join(':') }.join(' ')
      fields = row.map {|e| e.strip.gsub(/[\u0080-\u00ff]/, '').gsub(/\r\n/m, '').gsub(/\s/, '_').downcase}
      #puts `rails destroy model #{model_name} -f`
      #puts `rails generate model #{model_name} #{cli_fields} && rake db:migrate`
      #puts "rails generate model #{model_name} #{cli_fields} && rake db:migrate"
      puts model_name.camelize
      reload! #need to get the model into scope
      #fields.shift
      #
      #Since the model already exists and seems to be a reliable data source
      #we can extend it with our ar_util ....
      #this will allow m
      #puts model_name.camelize.constantize.truncate!
      model_name.camelize.constantize.truncate! #remove previous data import
    else
      #row.shift
      insert = fields.zip(row).reduce({}) {|h,f|
        k,v = f
        v.gsub!(/\r\n/m, '') #remove any crlfs
        v.gsub!(/[\u0080-\u00ff]/, '') #remove unicode chars
        #puts [k, v, f].map(&:inspect).join('|')
        if(!!k.to_s.match(/date|detected/))
          @ignore[-> {
            d = (v.split(/\//).reverse.map(&:to_i))
            d[0] += 2000 #make Y2K compliant
            d[1], d[2] = d[2], d[1]
            h.update(k.to_s.to_sym => DateTime.new(*d).to_s)
          }]
         else
           @ignore[->{
             h.update(k.to_s.to_sym => v)
           }]
         end
      }
      ap insert
      @ignore[->{
        r = model_name.camelize.constantize.create(insert)
      }]
    end
  }
  #special derivative methods go here they will be passed in as blocks or closures callbacks anonymouse funcitons you name it but keep it generic!!!!
  update_aggregates(file) if options[:update_stats] #keep historical aggregate results for charting etc
end

#import_csv('bing_stats', '/tmp/crawldetails_1_29_2012.csv')
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120129T064544Z.csv')

=begin
def import_csv(model_name, file)
  rows = CSV.parse(File.read(file))
  fields = rows.shift.map {|e| e.strip.gsub(/\s/, '_').downcase.to_sym}
  model_name.camelize.constantize.truncate! #remove previous data import
  model_name.camelize.constantize.import(fields, rows) #date needs to be fixed 2*pass would defeat the purpose
end
=end

#actual data

#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120129T191344Z.csv')
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120130T082752Z.csv')
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120130T225516Z.csv')
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120131T233514Z.csv')
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120201T214648Z.csv')
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120201T214648Z.csv')
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120203T074310Z.csv', :update_stats => true)
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120204T024250Z.csv', :update_stats => true)
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120205T012617Z.csv', :update_stats => true)
#import_csv('google_stats', '/tmp/Web_crawl_errors_www_apartmenthomeliving_com_20120206T012723Z.csv', :update_stats => true)
#
#aggregate data (currently an option in the import .. might need to move it out to keep it from becoming to terse)

#source data (checking for uniformity ... making sure this works for *any data)
#import_csv('google_source_stats', '/tmp/Web_crawl_error_sources_www_apartmenthomeliving_com_20120203T074312Z.csv')
#import_csv('google_source_stats', '/tmp/Web_crawl_error_sources_www_apartmenthomeliving_com_20120204T024303Z.csv')
#import_csv('google_source_stats', '/tmp/Web_crawl_error_sources_www_apartmenthomeliving_com_20120205T012707Z.csv')
#import_csv('google_source_stats', '/tmp/Web_crawl_error_sources_www_apartmenthomeliving_com_20120206T012827Z.csv')

#returned from mechanize download
#

@fix_date = ->(date) {
  d = (date.split(/\//).reverse.map(&:to_i))
  d[1] = (d[1] == 0)? 1 : d[1] #strange bug in date where the day of the month is 0 assume 1st unless the entire date is broken will return 1/1/1900
  d[0] += 2000 #make Y2K compliant
  d[1], d[2] = d[2], d[1]
  DateTime.new(*d).to_s rescue DateTime.new(1900, 1, 1) #replace invalid dates with 1/1/1900
}

def faster_import_csv(model_name, file, options = {})
  rows = CSV.parse(File.read(file))
  header = rows.shift.map {|e| e.gsub(/\s/, '_').downcase.to_sym} #make header rails compliant
  #need to fix dates
  ap header.map {|f| @type_guesser[f]}
  # guessing which column to fix the date yet bot are at -1 (last entry so I'll skip this generic part for now)
  rows.each {|row|
    @ignore[->{
      row[-1] = @fix_date[row[-1]] #invalid dates are 1/1/1900 .. yes google has invalid dates
    }, row[-1]]
  }
  model_name.camelize.constantize.truncate! #remove previous data import
  model_name.camelize.constantize.import(header, rows) #date needs to be fixed 2*pass would defeat the purpose
end

=begin
["Web_crawl_errors_www_apartmenthomeliving_com_20120206T234656Z.csv", "Web_crawl_error_sources_www_apartmenthomeliving_com_20120206T234656Z.csv"].each {|file|
  case(file)
  when /source/
    faster_import_csv('google_source_stats', '/tmp/' + file)
  else
    faster_import_csv('google_stats', '/tmp/' + file, :update_stats => false) #default
  end
}


=end
