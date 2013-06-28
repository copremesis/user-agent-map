
module Import
  class Import
    def initialize
      @fix_date = ->(date) {
        d = (date.split(/\//).reverse.map(&:to_i))
        d[1] = (d[1] == 0)? 1 : d[1] #strange bug in date where the day of the month is 0 assume 1st unless the entire date is broken will return 1/1/1900
        d[0] += 2000 #make Y2K compliant
        d[1], d[2] = d[2], d[1]
        DateTime.new(*d).to_s rescue DateTime.new(1900, 1, 1) #replace invalid dates with 1/1/1900
      }

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
    end

    def update_aggregates(file)
      z = GoogleStats.select("count(*) as number_found, detail").group(:detail).reduce({}) {|h,a|
        h.update(['_',a['detail'].downcase.gsub(/\s+|\-|\./, '_').gsub(/\(|\)/, '')].join.to_sym => a['number_found'].to_i)
      }.update(:date => (Time.parse(file.split(/\./)[0].split(/_/)[-1]) rescue Time.now), :file => file)
      GoogleStatAggregate.create(z)
    end

    def faster_import_csv(model_name, file, options = {})
      rows = CSV.parse(File.read(file))
      header = rows.shift.map {|e| e.gsub(/\s/, '_').downcase.to_sym} #make header rails compliant
      #need to fix dates
      #ap header.map {|f| @type_guesser[f]}
      # guessing which column to fix the date yet bot are at -1 (last entry so I'll skip this generic part for now)
      rows.each {|row|
        @ignore[->{
          row[-1] = @fix_date[row[-1]] #invalid dates are 1/1/1900 .. yes google has invalid dates
        }, row[-1]]
      }
      model_name.camelize.constantize.truncate! #remove previous data import
      model_name.camelize.constantize.import(header, rows) #date needs to be fixed 2*pass would defeat the purpose
      update_aggregates(file) if options[:update_stats] #keep historical aggregate results for charting etc
    end

    def import
      (Slurp.new).run.each {|file|
        case(file)
        when /source/
          faster_import_csv('google_source_stats', '/tmp/' + file)
        else
          faster_import_csv('google_stats', '/tmp/' + file, :update_stats => true) #default
        end
      }
    end
  end
end
