
#dependencies
require 'net/ssh' #for world_clock
require 'timeout' #for world_clock & main controller
require 'csv'     #for import/import
require 'openssl' #for encryption/cipher
require 'open-uri' #main controller callbacks


#lib extensions
require 'encryption/cipher'       #keep clear text password out of reach of grep
#cipher for docstoc auth request
#this is used to obtain a ticket when sending files
class String
  def encrypt(options = {})
    Encryption::Cipher.new(options).encrypt(self)
  end

  def decrypt(options = {})
    Encryption::Cipher.new(options).decrypt(self)
  end
end

require 'world_clock/world_clock' #world clock: gathers times of all machines in our network
require 'extensions/extensions'   #active record truncate!! mysql/sqlite3
require 'import/slurp'            #downloads CSVs from google using mechanize
require 'import/import'           #imports the parsed CSV
require 'htop/htop'               #better server data collection
require 'gantt/gantt'             #visualize the time shift
require 'cache_me/cache_me'       #bypass redundant SQL request to memcache
