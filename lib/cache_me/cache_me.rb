module CacheMe
  class CacheMe
    def self.make_key(a) 
      Digest::MD5.hexdigest( 
        a.map {|e|
          case e.class
=begin
          when Range
            Rails.logger.info(e.class)
            Rails.logger.info('what is the deal?')
            [e.begin, e.end].to_json
=end
          when String, Fixnum
            e
          else
            e.to_s
          end
        }.join(':')
      )
    end

    def self.graceful_death(*args)
      res = nil
      begin
        res = yield(*args)
      rescue => e
        Rails.logger.info(args.inspect)
        Rails.logger.error(e)
        Rails.logger.info('Anonymous block Failed. Nothing to Cache!!!')
      end
      return res
    end
    
    def self.memcache_bypass(*args)
      key = make_key(args)
      Rails.logger.info("MEM:Searching MemCache using key: #{key}")
      res = Rails.cache.fetch(key) 
      if res == nil
        Rails.logger.info('MEM:Not Found searching DB...')
        res = graceful_death(*args) { yield(*args) }
        if(res != nil)
          Rails.logger.info('MEM:Writing MemCache')
          Rails.cache.write(key, res)
        end
      end
      #Rails.logger.info("MEM:Found!!! #{res.to_json}")
      #Rails.logger.info("MEM:Found!!!") 
      res
    end
  end
=begin
  class ActiveRecord::Base
    class << self
      class_eval <<-FOO
        def find_vins(*args)
          Rails.logger.info('MEM: hijacked!!!')
          super(*args)
        end
      FOO
      
      def find(*args) #memcached find
        key = [self.name, args].flatten.join('_')
        memcache_bypass(key) { super(args) }
      end 

      def where(opts, *rest)
        key = [selectf.name, make_key(opts), make_key(rest)].join('_')
        memcache_bypass(key) { super(opts, rest) }
      end

      def method_missing(m, *args, &boxlock)  
        key = [self.name, m, make_key(args)].join('_')
        memcache_bypass(key) { super(m, args, block) }
      end  

      private

      def make_key(o)
        (o.class == Array)? o.join('_'): o.map {|k,v| [k.to_s,v].join('_')}.join('_') rescue o
      end

      def memcache_bypass(key)
        Rails.logger.info("Searching MemCache using key: #{key}")
        res = Rails.cache.fetch(key) 
        if res == nil
        Rails.logger.info('Netot Found searching DB...')
        res = yield
        Rails.logger.info('Writingiting MemCache')
        Rails.cache.write(key, res)
      end
    end
  end
=end
end
