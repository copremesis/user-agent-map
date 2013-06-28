class VinLocation
  attr_reader :character_set
  def initialize
    @character_set = [*'A'..'Z'] + [*'1'..'9'] + ['0']
    @country_codes = {
      #Africa
      'AA-AH' => 'South Africa',
      'AJ-AN' => 'Ivory Coast',
      'BA-BE' => 'Angola',
      'BF-BK' => 'Kenya',
      'BL-BR' => 'Tanzania',
      'CA-CE' => 'Benin',
      'CF-CK' => 'Madagascar',
      'CL-CR' => 'Tunisia',
      'DA-DE' => 'Egypt',
      'DF-DK' => 'Morocco',
      'DL-DR' => 'Zambia',
      'EA-EE' => 'Ethiopia',
      'EF-EK' => 'Mozambique',
      'FA-FE' => 'Ghana',
      'FF-FK' => 'Nigeria',
      #Asia
      'JA-JT' => 'Japan',
      'KA-KE' => 'Sri Lanka',
      'KF-KK' => 'Israel',
      'KL-KR' => '(South) Korea',
      'LA-L0' => 'China',
      'MA-ME' => 'India',
      'MF-MK' => 'Indonesia',
      'ML-MR' => 'Thailand',
      'NF-NK' => 'Pakistan',
      'NL-NR' => 'Turkey',
      'PA-PE' => 'Philippines',
      'PF-PK' => 'Singapore',
      'PL-PR' => 'Malaysia',
      'RA-RE' => 'United Emirates Arab',
      'RF-RK' => 'Taiwan',
      'RL-RR' => 'Vietnam',
      'RS-R0' => 'Saudi Arabia',
      #europe
      'SA-SM' => 'United Kingdom',
      'SN-ST' => 'Germany',
      'SU-SZ' => 'Poland',
      'S1-S4' => 'Latvia',
      'TA-TH' => 'Switzerland',
      'TJ-TP' => 'Czech Republic',
      'TR-TV' => 'Hungary',
      'TW-T1' => 'Portugal',
      'UH-UM' => 'Denmark',
      'UN-UT' => 'Ireland',
      'UU-UZ' => 'Romania',
      'U5-U7' => 'Slovakia',
      'VA-VE' => 'Austria',
      'VF-VR' => 'France',
      'VS-VW' => 'Spain',
      'VX-V2' => 'Serbia',
      'V3-V5' => 'Croatia',
      'V6-V0' => 'Estonia',
      'WA-W0' => 'Germany',
      'XA-XE' => 'Bulgaria',
      'XF-XK' => 'Greece',
      'XL-XR' => 'Netherlands',
      'XS-XW' => 'USSR',
      'XX-X2' => 'Luxembourg',
      'X3-X0' => 'Russia',
      'YA-YE' => 'Belgium',
      'YF-YK' => 'Finland',
      'YL-YR' => 'Malta',
      'YS-YW' => 'Sweden',
      'YX-Y2' => 'Norway',
      'Y3-Y5' => 'Belarus',
      'Y6-Y0' => 'Ukraine',
      'ZA-ZR' => 'Italy',
      'ZX-Z2' => 'Slovenia',
      'Z3-Z5' => 'Lithuania',
      #north america
      '1A-10' => 'United States',
      '2A-20' => 'Canada',
      '3A-3W' => 'Mexico',
      '3X-37' => 'Costa Rica',
      '38-30' => 'Cayman Islands',
      '4A-40' => 'United States',
      '5A-50' => 'United States',
      #oceania
      '6A-6W' => 'Australia',
      '7A-7E' => 'New Zealand',
      '8A-8E' => 'Argentina',
      '8F-8K' => 'Chile',
      '8L-8R' => 'Ecuador',
      '8S-8W' => 'Peru',
      '8X-82' => 'Venezuela',
      '9A-9E' => 'Brazil',
      '9F-9K' => 'Colombia',
      '9L-9R' => 'Paraguay',
      '9S-9W' => 'Uruguay',
      '9X-92' => 'Trinidad &amp; Tobago',
      '93-99' => 'Brazil'
    }
  end

  #return subset from the given params
  def range(p, q)
    #puts ['range', p, q].join(' ')
    @character_set[@character_set.index(p)..@character_set.index(q)] rescue []
  end

  def fubar
    begin
      return yield
    rescue => e
      puts e.backtrace
      #puts 'sleeping ..'
      #sleep 10
      return []
    end
  end

  def country_set(range)
    fubar {
      #puts range
      f = range.split('-')
      s = f[0]
      t = f[1]
      continent = s[0]
      r = range(s[1], t[1])
      ([continent]*r.size).zip(r).map(&:join)
    }
  end

  def location(code)
    @country_codes.each {|code_range, country|
      return country if(country_set(code_range).include?(code))
    }
    return 'not assigned'
  end

  #run against all combinations to build cache
  #after this operation is performed there becomes zero logic
  #with O(1) lookup 
  def precache
    all_possibilites = @character_set.map {|char|
      ([char] * @character_set.size).zip(@character_set).map(&:join)
    }.flatten
  end


end

require 'benchmark'


Benchmark.bm { |x|
  x.report("%-40s" % 'init lookup version:') {
    @v = VinLocation.new
  }
  x.report("%-40s" % 'build precache:') {
    all_possibilites = @v.precache
  }
=begin
  x.report("%-40s" % 'create quick hash:') {
    @h = all_possibilites.reduce({}) {|h, code|
      h.update(code => @v.location(code))
    }
  }
=`end
  x.report("%-40s" % 'load static hash:') {
    load 'location_data.rb'
  }
  x.report("%-40s" % 'lookup using O(n) search:') {
    @v.location('93')
  }
  x.report("%-40s" % 'lookup using O(1) hash:') {
    @h['93']
  }
}
nil

#@h
