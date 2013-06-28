



=begin

->(ip) {
  @geo ||= GeoIP.new(Rails.root.join('GeoLiteCity.dat').to_s)
  r = @geo.city(ip)
  [r.latitude, r.longitude]
}['24.252.93.24']
=end


imgs = ["images.cars.com/supersized/DMI/2208445/J00213B/01.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/02.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/03.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/04.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/05.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/06.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/07.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/08.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/09.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/10.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/11.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/12.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/13.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/14.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/15.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/16.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/17.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/18.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/19.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/20.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/21.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/22.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/23.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/24.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/25.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/26.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/27.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/28.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/29.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/30.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/31.jpg", "images.cars.com/supersized/DMI/2208445/J00213B/32.jpg"]


=begin
imgs.each {|img|
  %x[wget #{img}]
}

=end

transponder = {
 property_id: 394867,
 template: 1.1,
 post_stamp: Time.now.to_i,
 filename: 'Hallidayprop.jpg'
}
"https://mymedia.apartments.com/imgs/public/mmcl-#{transponder[:property_id]}-#{transponder[:template]}-#{transponder[:post_stamp]}.#{transponder[:filename]}"


=begin

def rnd_boolean()
  retval = ''
  retval += 'http://' if rnd_boolean
  retval += "www." if rnd_boolean
  retval += Forgery(:Internet).domain_name
  rnd_int(1,5).times { retval += "/" + rnd_words(1,1) if rnd_boolean }
  retval
end

=end

(0..100).map {
rand(2) 
}
