class PropertyCompare < ActiveRecord::Base
  def good_url
    return (self.dupe_url.size > 0)? self.dupe_url : self.overview_url
  end
end
