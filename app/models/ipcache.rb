class Ipcache < ActiveRecord::Base
  include Extensions
  include CacheMe
end
