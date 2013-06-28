
#strict mixin module to add common functionality to models like
#an actual truncate feature .... warning use with caution!!!
#
#add this line to your model:
#
#include ArUtil
#
#then invoke using YourModel.truncate!
#
#Voila!
module Extensions
  class ActiveRecord::Base
    class << self
      def truncate!(options = {})
        sql = case self.configurations[Rails.env]['adapter'] #dunno why this isn't in scope all of a sudden
              when "sqlite3"
                "DELETE FROM #{self.table_name}"
              else
                "truncate #{self.table_name}"
              end
        raw = self.connection
        raw.execute(sql)
      end


=begin
      alias_method :default_find, :find
      def find(*args)
        puts 'memcache hijack goes here'
        default_find(args)
      end
=end
    end
  end
#getting closer
=begin
  class ActiveRecord::DynamicFinderMatch
    class << self
      alias_method :default_match, :match
      def match(method)
        puts(['def method?', method].join(': '))
        
        default_match(method) 
      end
    end
  end
=end

  module ActiveRecord
    module Associations
      class CollectionProxy # :nodoc:
        def method_missing(method, *args, &block)
          puts 'supper hijacked'
          super(method, *args, block)
        end
      end
    end
  end
end
