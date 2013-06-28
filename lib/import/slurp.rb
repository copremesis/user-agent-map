
module Import
  class Slurp
    def initialize
      @agent = Mechanize.new
      @page = @agent.get 'http://www.gmail.com'
      form = @page.forms.first
      form.Email = "TRtzafnRQzT6rJJcH6GnGsL6ks9LflmsNniiwahXr3o=\n".decrypt(:key => Ahl2ahl3Checker::Application.config.secret_token)
      form.Passwd = "F6h1Ex7hDK1GGJqX83uQFQ==\n".decrypt(:key => Ahl2ahl3Checker::Application.config.secret_token)
      @page = @agent.submit form
    end

    def download(url)
      
      @page = @agent.post(url)

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
      #these links were copied out of firebug when i clicked on the urls ... looks like as soon as we are logged into google any resource associated with the user/pass is seen
     # resources = ['https://www.google.com/webmasters/tools/crawl-errors-dl?hl=en&siteUrl=http://www.apartmenthomeliving.com/&security_token=XPKOYm1TpX5AUPLM_IiumIPfzO8:1328545691033&type=0',
     # 'https://www.google.com/webmasters/tools/crawl-error-parents-dl?hl=en&siteUrl=http://www.apartmenthomeliving.com/&security_token=YpbW753CO9rdiqJTDansd0hWVb8:1328548892590&type=0']

      resources = %w(https://www.google.com/webmasters/tools/gwt/CRAWLERRORS_READ?hl=en&siteUrl=http%3A%2F%2Fwww.apartmenthomeliving.com%2F#t2=4 https://www.google.com/webmasters/tools/crawl-error-parents-dl?hl=en&siteUrl=http://www.apartmenthomeliving.com/&security_token=YpbW753CO9rdiqJTDansd0hWVb8:1328548892590&type=0)


      files = []
      threads = resources.map {|url|
        Thread.new {
          files << download(url)
        }
      }
      threads.map(&:join)
      files #get a list of files downloaded
    end
  end
end
