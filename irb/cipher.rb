#!/usr/bin/ruby
require 'openssl'
require 'digest/sha1'

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

module Encryption
  class Cipher
    def initialize(options = {})

      @options = {
        :algorithm => 'aes-128-cbc',
        :method    => 'encrypt',
        :key       => '37e2678080614c52',
        :iv        => '9b64f8d6dda503db'
      }
      @options.update(options)

      @convert = lambda {|c, string|
        c.key = @options[:key]
        c.iv  = @options[:iv]
        res = c.update(string)
        res << c.final
        res
      }
    end

    def encrypt(string)
      c = OpenSSL::Cipher::Cipher.new(@options[:algorithm])
      c.encrypt
      [@convert.call(c, string)].pack("*m")
    end

    def decrypt(base64_string)
      #must ask for key or this whole project
      #is pointless

      string = base64_string.unpack("*m")[0]
      c = OpenSSL::Cipher::Cipher.new(@options[:algorithm])
      c.decrypt
      @convert.call(c, string)
    end

    def self.get_post_creds
      ['apartmenthomeliving'.encrypt, 'live4fun'.encrypt]
    end

    def self.test_inverse
      ['apartmenthomeliving'.encrypt.decrypt, 'live4fun'.encrypt.decrypt]
    end

    def self.test_size(size, options = {})
      large_string = (0..size).map {('a'..'z').map[rand(27)] }.join('')
      large_string == large_string.encrypt(options).decrypt(options)
    end

    def self.test_algo_switch
      %w(128 192 256).map {|bits|
        self.test_size(10000, :algorithm => "aes-#{bits}-cbc", :key => rand(1<<bits.to_i).to_s(base=16))
      }
    end

    def self.test_file_encryption
      File.new(__FILE__).read.encrypt
    end
  end
end
