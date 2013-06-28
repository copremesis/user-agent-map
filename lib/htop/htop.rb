

#Tue Jan 18 16:43:55 CST 2011
#htop.rb
#requirements: htop and df  is installed on all all machines listed
#the user and password are the same on all machines



module Htop
  class Parse
    def initialize(ansi_io)
      @ansi_io = ansi_io
      @reggies = {
        '\[1;\d{2}r' => "",
        '\(B' => "",
        '\)0' => "",
        '\[\?\d+h' => "",
        '\[m' => "",
        '\[4l' => "",
        '=' => "",
        '\[\?25l' => "",
        '\[\d+;\d+m' => "",
        '\[H' => "",
        '\[J' => "",
        '\[1B' => "",
        '\[\d+m' => "",
        '\[1m332' => "",
        '\[\d+;\d+H' => "\n  ",
        '\[\d+J' => "",
        '\[\d+d' => "",
        '\[\d+X' => "",
    #    '\x0F' => "",
      }

    end

    def parse
      @reggies.each {|regex, subst|
        @ansi_io.gsub!(Regexp.new("\\e" + regex), subst)
      }
      @ansi_io
    end

    def export(file)
      File.open(file, 'w') { |fd| fd.print @ansi_io }
    end

  end

  class SSHRPC
    def initialize
      @hosts = %w{frankmusician.com wardlawoffice.co dragonwrench.com}
    end

    def run_remote(ssh_tunnel, cmd)
      res = ''
      return res if ssh_tunnel == nil
      ssh_tunnel.open_channel {|channel|
        channel.exec(cmd) {
          channel.on_data {|ch, data|
            res << data
          }
          yield channel if block_given?
        }
      }
      Rails.logger.info(res)
      res
    end

    def rr(cmd, host, args)
      begin
        Timeout::timeout(args[:timeout] || 30) {
          user = args[:username]
          res = ''
          Rails.logger.info(['connecting to', host].join(': '))
          Net::SSH.start(host, user, :password => args[:password]) {|ssh|
            #puts "\nconnecting to: #{host}"
            ssh.open_channel {|channel|
              channel.exec(cmd) {
                channel.on_data {|ch, data|
                  res << data
                }
                yield channel if block_given?
              }
            }
          }
          res
        }
      rescue => e
        Rails.logger.info(['Timeout with this host:', host].join(' '))
        return 'Timeout'
      end

    end

    def htop_remote
      #status = {}
      @threads = []
      @status = {}
      @lan.each {|host, ssh_tunnel|
        @threads << Thread.new {
          begin
            @status[host] = run_remote(ssh_tunnel, "bash")  {|channel|
              channel.send_data("export TERM=screen && htop\n")
              channel.send_data("q")
              channel.send_data("df -h\n") #need to look for san here
              channel.send_data("echo 'time:'$(date)\n") #need to parse this :time => date
              #channel.send_data("echo 'cron_count:'$(ps ax | grep crond | wc -l)\n")
                #we can also look for any critical processes that should be running here for machines
              channel.send_data("exit\n")
            }
          rescue => e
            @status[host] = e.to_s
          end
        }
      }

      @threads.map(&:join) #wait for threads to complete or time out

      condition = Proc.new { |s| s.busy? }
      loop do
        @tunnels.delete_if { |ssh| !ssh.process(0.1, &condition) }
        break if @tunnels.empty?
      end
      @status
    end

    def hr
      @threads = []
      @status = {}
      @hosts.each {|host|
        @threads << Thread.new {
          Timeout::timeout(300) {
            begin
              @status[host] = rr("bash", "#{host}", :username => "left invalid on purpose", :password => "left invalid on purpose".decrypt) { |ssh|
                ssh.send_data("export TERM=screen && htop\n")
                ssh.send_data("q")
                ssh.send_data("df -h\n")
                ssh.send_data("echo 'time:'$(date)\n")
                ssh.send_data("echo 'crond_count:'$(ps ax | grep crond | grep -v grep | wc -l)\n")
                ssh.send_data("exit\n")
              }
            rescue => e
              @status[host] = e.to_s
            end
          }
        }
      }
      @threads.map(&:join) #wait for threads to complete or time out
      @status
    end

    def self.run
      sys = self.new
      sys.hr #htop_remote
    end

  end


  class Pipe
    def htop_local
      IO.popen("bash", "r+") {|f|
        f.puts "htop";
        f.puts "q";
        f.puts "df -h";
        f.puts "exit";
        f.read
      }
    end

    def run_remote(cmd, host, args)
      user = args[:username]
      res = ''
      Net::SSH.start(host, user, :password => args[:password]) {|ssh|
        ssh.open_channel {|channel|
          channel.exec(cmd) {
            channel.on_data {|ch, data|
              res << data
            }
            yield channel if block_given?
          }
        }
      }
      res
    end

    def htop_remote(host, args)
      run_remote('export TERM=screen && htop', host, args) {|channel|
        channel.send_data("q")
      }
    end
  end

  class Htop
    def self.run#(host, args)
      #uncooked = Pipe.new.htop_remote(host, args).sub(/\r.*/, "\n")
      uncooked = Pipe.new.htop_local.sub(/\r.*/, "\n")
      cooked = Parse.new(uncooked).parse
    end

    def self.get_system_info
      h = {}
      SSHRPC.run.each {|k,v|
        h[k] = Parse.new(v.sub(/\r.*/, "\n")).parse
      }
      h
    end

    def self.db_handler(device_name, server_row)
      device = server_row.devices.where(:name => device_name).first || server_row.devices.create(:name => device_name)
      t = Time.new
      yield device, Time.local(t.year, t.month, t.day, t.hour, t.min, 0)  #set time to be at the exact minute
    end

    def self.parse(rpc_out, server_row)
      sys_info = rpc_out.split(/\n/)
      k = sys_info.index(sys_info.grep(/mapper/)[0])
      sys_info << [sys_info[k], sys_info[k+1]].join('') if k

      memory_device = ->(s='mem') {
        mem = $1
        inuse, capacity = mem.sub(/MB/, '').split(/\//).map(&:to_f)
        current_percentage = (inuse/capacity * 100)
        self.db_handler(s, server_row) {|device, date|
          device.device_attributes.create(:name => 'percentage', :value => current_percentage, :date => date)
          device.device_attributes.create(:name => 'inuse', :value => inuse, :date => date)
          device.device_attributes.create(:name => 'capacity', :value => capacity, :date => date)
        }
      }
      sys_info.each {|line|
        case(line)
        when /^\s+(\d+|CPU)[^\d+]+(\d+\.\d)%.*$/ #added CPU in regex for single cpu machine ... (we really have machines like theses!!!)
          cpu_match = $1
          percentage = $2 || 0.0
          device_name = "cpu#{(!!cpu_match.match(/cpu/i)? '' : cpu_match)}"
          self.db_handler(device_name, server_row) {|device, date|
            device.device_attributes.create(:name => 'percentage', :value => percentage, :date => date)
          }
        when /^\s+Mem[^\d+]+(\d+\/\d+MB).*$/
          memory_device.call
        when /^\s+Swp[^\d*]+(\d+\/\d+MB).*$/
          memory_device.call('swp')
        when /^(\/dev\/\S+)\s+(\d+(\.\d)?[GMK])\s+(\d+(\.\d)?[GMK])\s+(\d+(\.\d)?[GMK])\s+(\d+)%\s+(\/.*)$/
          device_name, capacity, inuse, available, percentage, mount_point = $1, $2, $4, $6, $8, $9
          self.db_handler(device_name, server_row) {|device, date|
            device.device_attributes.create(:name => 'percentage', :value => percentage, :date => date)
=begin
            device.device_attributes.create(:name => 'capacity', :value => capacity, :date => date)
            device.device_attributes.create(:name => 'inuse', :value => inuse, :date => date)
            device.device_attributes.create(:name => 'available', :value => available, :date => date)
            device.device_attributes.create(:name => 'mount_point', :value => mount_point, :date => date)
=end
          }
        when/^Cpu.*\s(\d+\.\d+)%id,\s.*$/
          self.db_handler('average_cpu_idle_usage', server_row) {|device, date|
            percentage = $1
            device.device_attributes.create(:name => 'percentage', :value => percentage, :date => date)
          }
        else
          #do nothing
        end
      }
    end

    def self.to_obj(rpc_out, server_row)
      sys_info = rpc_out.split(/\n/)
      k = sys_info.index(sys_info.grep(/mapper/)[0])
      sys_info << [sys_info[k], sys_info[k+1]].join('') if k

      obj = {}

      memory_device = ->(obj, s='mem') {
        mem = $1
        inuse, capacity = mem.sub(/MB/, '').split(/\//).map(&:to_f)
        current_percentage = (capacity == 0.0)? 0.0: (inuse/capacity * 100).round(1)
        obj.update(s.to_sym => current_percentage) 
      }
      sys_info.each {|line|
        case(line)
        when /^\s+(\d+|CPU)[^\d+]+(\d+\.\d)%.*$/ #added CPU in regex for single cpu machine ... (we really have machines like theses!!!)
          cpu_match = $1
          percentage = $2
          device_name = "cpu#{(!!cpu_match.match(/cpu/i))? '1' : cpu_match}"
          obj.update(device_name.to_sym => percentage)
        when /^\s+Mem[^\d+]+(\d+\/\d+MB).*$/
          memory_device.call(obj)
        when /^\s+Swp[^\d*]+(\d+\/\d+MB).*$/
          memory_device.call(obj, 'swp')
        when /^(\/dev\/\S+)\s+(\d+(\.\d)?[GMK])\s+(\d+(\.\d)?[GMK])\s+(\d+(\.\d)?[GMK])\s+(\d+)%\s+(\/.*)$/
          device_name, capacity, inuse, available, percentage, mount_point = $1, $2, $4, $6, $8, $9
          obj.update(device_name.to_sym => percentage)
        when /^time:(.*)$/
          obj.update(:time => Time.parse($1))
        when /^crond_count:(.*)$/
          obj.update(:cronds => $1)
        when /ahlshared/
          obj.update(:san_mounted => 'true')
        else
          #do nothing
        end
      }
      obj[:san_mounted] = obj[:san_mounted] || 'false' #keep logic consistent in the front end
      obj
    end

    def self.collect_system_info
      self.get_system_info.each {|machine, htop|
        server_row = Server.where(:server => machine).first || Server.create(:server => machine)
        parse(htop.gsub(/\x0F/, ''), server_row)
      }
      nil
    end

#modifying routine perhaps the original should be unscaved for debuggin
    def self.merge(obj)
      merge_max_value = ->(hash, key, regex) {
        hash.update(key => hash.select {|k,v| k.to_s.match(regex) }.values.reject {|x| x == ''}.map(&:to_i).max)
        hash.delete_if {|k,v| k.to_s.match(regex) }
      }
      merge_max_value[obj, :disk_usage, /dev/]
      merge_max_value[obj, :processor, /cpu/]
      merge_max_value[obj, :ram, /mem/]
      merge_max_value[obj, :swap, /swp/]
    end

    def self.time_diff(obj)
      obj[:time_diff] = obj[:time] - Time.now rescue ''
    end

    def self.normalize(obj)
      keys = obj.reduce([]){|a, e| a | e.keys }
      keys.each {|key| obj.each {|row| row[key] = row[key] || '' }}
      obj.map {|row| self.merge(row) }
      obj.map {|row| self.time_diff(row) } #do some magic with time
      #obj.sort_by {|h| h[:server] }
      obj.map {|row| Hash[row.sort] }
      #obj.sort_by {|h| h[:server] }
      #obj.map {|row| Hash[row.sort] }
      #obj.sort_by {|h| h[:server] }
    end

    def self.obj_system_info
        self.normalize(
          self.get_system_info.map {|machine, htop|
            {}.update(:server => machine).update(self.to_obj(htop.gsub(/\x0F/, ''), machine))
          }
        ).sort_by {|h| h[:server] }
    end
  end
end


