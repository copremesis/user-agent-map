

class GWTDataSlurp
  def initialize
    @agent = Mechanize.new
    @page = @agent.get 'http://www.gmail.com'
    form = @page.forms.first
    form.Email = 'apartmentsconsole@gmail.com'
    form.Passwd = '4partments'
    @page = @agent.submit form
  end

  def download(url)
    @page = @agent.get(url)
    file = @page.content.split(/\n/)
    File.open("/tmp/#{@page.filename}", 'w') {|fd|
      file.each {|line|
        begin
          fd.puts line
        rescue => e
          #puts e
          #puts line
          #make use of your KeyValue table:
          #md5(data) -> (data) then count # of collisions instead of overwriting ..
          #this can be a multi-use table in use of checking for poor urls or also in caching data in general
        end
      }
    }
    @page.filename #return the name of the file returned
  end

  def run
    resources = ['https://www.google.com/webmasters/tools/crawl-errors-dl?hl=en&siteUrl=http://www.apartmenthomeliving.com/&security_token=XPKOYm1TpX5AUPLM_IiumIPfzO8:1328545691033&type=0',
    'https://www.google.com/webmasters/tools/crawl-error-parents-dl?hl=en&siteUrl=http://www.apartmenthomeliving.com/&security_token=YpbW753CO9rdiqJTDansd0hWVb8:1328548892590&type=0']
    files = []
    threads = resources.map {|url|
      Thread.new {
        puts 'thread starting...'
        files << download(url)
        puts 'thread complete'
      }
    }
    threads.map(&:join)
    puts 'done'
    files #get a list of files downloaded
  end
end

#(GWTDataSlurp.new).run()
