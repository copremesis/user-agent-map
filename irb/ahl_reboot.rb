module MultiSSH

  def multi_thread_hosts(hosts)
    threads = []
    status = {}
    hosts.each {|host|
      threads << Thread.new {
        username =  "VzsusP8mFSzKgEfNRJUsdA==\n".decrypt(:key => Ahl2ahl3Checker::Application.config.secret_token)
        password  = "PkBwM/LhY+feKRzjwIh/qw==\n".decrypt(:key => Ahl2ahl3Checker::Application.config.secret_token)
        begin
          status[host] = run_remote("bash", host , :username => username, :password => password) { |ssh|
                           yield(ssh)
                         }
        rescue => e
          status[host] = e.to_s
        end
      }
    }
    threads.map(&:join) #wait for threads to complete or time out
    status
  end

  def run_remote(cmd, host, args)
    begin
      Timeout::timeout(args[:timeout] || 30) {
        user = args[:username]
        res = ''
        Rails.logger.info(['connecting to', host].join(': '))
        puts (['connecting to', host].join(': '))
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
      puts(['Timeout with this host:', host].join(' '))
      return 'Timeout'
    end
  end
end

#deploy  ALL=(ALL:ALL) NOPASSWD: ALL #need to add this to your sudoers file
#use visudo!!!!

class AHLReboot
  include MultiSSH
  def apaches
    #hosts = [*1..4].map {|i| "awahl#{i}.apts.classifiedventures.com" }
    hosts = %w(172.31.20.33)
    multi_thread_hosts(hosts) {|ssh|
      cmds = <<-RUN
        sudo echo #{rand((1<<64)).to_s(base=16)} > /tmp/foo
        cat /tmp/foo
        exit
      RUN
      ssh.send_data(cmds)
    }
  end
end

AHLReboot.new.apaches.each {|host, data|
  puts host
  puts data
}
nil



#http://bash.org/?browse&p=03


