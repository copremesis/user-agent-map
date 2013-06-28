

module WorldClock
  class WorldClock

    def self.run_remote(cmd, host, args)
      user = args[:username]
      res = ''
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
    end

    def self.times
      servers = %w{ahlruby1 ahlruby2 ahlruby3 ahlruby4 ahlruby5 ahlruby6 ahlruby7 ahlruby8 ahlruby01 ahlruby02 ahlrpt1 ahlproc1 ahlproc2 ahlsauce1 ahlsauce2 awahl1 awahl2}
      #servers = %w{ethereal azagthoth}
      self.multi_threaded(servers)
      #self.round_robin(servers)
    end

    private
    def self.creds
      creds = {
        :username => "VzsusP8mFSzKgEfNRJUsdA==\n".decrypt(:key => Ahl2ahl3Checker::Application.config.secret_token),
        :password => "PkBwM/LhY+feKRzjwIh/qw==\n".decrypt(:key => Ahl2ahl3Checker::Application.config.secret_token)
      }
    end

    def self.ignore
        begin
          return yield
        rescue => e
          #print "\r#{e.backtrace}"
          print "\r#{e}"
        end
        return e
    end

    def self.round_robin(servers)
      x = servers.map{|m| [m, 'apts.classifiedventures.com'].join('.')}.map() {|server|
        time = self.ignore(){run_remote('date', server, self.creds)}
        h = {:server => server, :time => time}
      }
    end

    def self.multi_threaded(servers)
      x, t = [], []
      servers.each_with_index {|server, i|
        full_host = [server, 'apts.classifiedventures.com'].join('.')
        t << Thread.new {
          x[i] = Timeout::timeout(10) {
          v = {:server => server.to_sym, :time => self.ignore(){run_remote('date', full_host, self.creds) }}
        } rescue {:server => server.to_sym, :time => 'TimeoutError' }
          #x[i] = {:server => server.to_sym, :time => self.ignore(){run_remote('date', server, :username => 'rob', :password => '') } }
        }
      }
=begin
    #learning on how to do a wait manually but the .join method works better
    #wait till all threads are done
    #while(!@has_nil[t]) do
    while((t.reduce(false) {|status, t| status | !!t.status} != false) && (!@has_vals[[nil, 'sleep'], t.map(&:status)]) && !t.empty?) do
      print "\r#{t.map(&:status).inspect} has_nil:#{@has_nil[t.map(&:status)]} #{' ' * 40}"
    end
=end
      #return array of hashes with server_name -> time_of_server
      t.map(&:join) #wait the correct way
      x
    end
  end
end
