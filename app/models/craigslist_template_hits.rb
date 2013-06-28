class CraigslistTemplateHits < ActiveRecord::Base
  include CacheMe

  def self.per_day(unit, property_id)
    CacheMe.memcache_bypass(unit, property_id, 'per_day') {
      ->(property_id, range){
        histo = {}
        CraigslistTemplateHits.select("count(referrer) as hits, referrer, post_date, template, ip")
                              .where(:post_date => range)
                              .where(:property_id => property_id)
                              .where("referrer  like 'http%.craigslist.org/%.html'")
                              .group(:referrer)
                              .order("post_date desc").each {|row|
                                day = row.post_date.to_s[0,10]
                                histo[day] = histo[day] || 0
                                histo[day] += 1
                              }
        histo.map{|date, number_of_posts| {:date => date, :number_of_posts => number_of_posts}}.to_json
      }[property_id, get_range(unit)]
    }
  end

  def self.ghost_inquiry(unit, property_id)
    CacheMe.memcache_bypass(unit, property_id, 'ghost_inquiry') {
      range = get_range(unit)
      click = ->(e, url) { "<div class=click event='hits' url='#{url}' property_id='#{property_id}'>#{e}</div>" }
      link = ->(e) { "<a target='_blank' href='#{e}'> #{e} </a>" }
      self.select("count(referrer) as hits, referrer, post_date, template, ip")
          .where(:post_date => range)
          .where(:property_id => property_id)
          .where("referrer  like 'http%.craigslist.org/%.html'")
          .group(:referrer)
          .order("post_date desc").map {|row|
            row = {
              :hits => click[row.hits, row.referrer],
              :post_date => row.post_date.to_s,
              :referrer => link[row.referrer],
              :template => row.template
            }
          }.to_json
    }
  end

  def self.ghost_summary(unit, page, property_id)
    CacheMe.memcache_bypass(unit, page, property_id) {
      range = get_range(unit)
      click = ->(e) { "<div class=click event='ghost_inquiry' property_id='#{e}'>#{e}</div>" }
      click2 = ->(ad_count,id) { "<div class=click event='per_day' property_id='#{id}'>#{ad_count}</div>" }
      if property_id
        self.select("property_id, count(distinct referrer) as ads")
            .where(:log_stamp => range)
            .where("referrer  like 'http%.craigslist.org/%.html'")
            .where(:property_id => property_id)
            .group(:property_id).order("ads desc").offset(page * 20)
            .limit(20).map {|row|
              row = {
                :property_id => click[row.property_id],
                :ads => click2[row.ads, row.property_id]
              }
        }.to_json
      else
        self.select("property_id, count(distinct referrer) as ads")
            .where(:log_stamp => range)
            .where("referrer  like 'http%.craigslist.org/%.html'")
            .group(:property_id).order("ads desc").offset(page * 20).limit(20).map {|row|
               row = {
                 :property_id => click[row.property_id],
                 :ads => click2[row.ads,row.property_id]
               }
        }.to_json
      end
    }
  end

  def self.template_hit_distribution(unit, property_id)
    CacheMe.memcache_bypass(unit, property_id) {
      range = get_range(unit) 
      if(property_id)
        self.select("template, count(template) as freq")
            .where(:property_id => property_id)
            .where(:log_stamp => range)
            .group(:template)
            .order("freq DESC").to_json
      else
        self.select("template, count(template) as freq")
                             .where(:log_stamp => range)
                             .group(:template)
                             .order("freq DESC").to_json
      end
    }
  end

  private

  def self.get_range(unit)
    duration = 1.send(unit).ago
    range = (duration..Time.now.utc)
  end

end
