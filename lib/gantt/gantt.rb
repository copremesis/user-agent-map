
class Gantt
  @@defaults = {
    :starttime => 1.day.ago,
    :endtime => 1.day.from_now
  }
  def self.generate_xlabels(opts={})
    # init the time variables if running in the console
    endtime = (opts[:endtime] || @@defaults[:endtime])
    starttime = (opts[:starttime] || @@defaults[:starttime])
    ticks = (opts[:ticks] || 10)
    # divide the duration into `ticks` equal parts
    step = (endtime - starttime).to_f / ticks.to_f
    # init the first item and loop the rest
    thisTime = starttime
    thisMin = ((thisTime.strftime("%M").to_f / 5.0).ceil * 5).to_s
    thisMin = "0#{thisMin}"  unless thisMin.size > 1
    rOut = [thisTime.strftime("%a %I:%M") + thisTime.strftime("%p").first.downcase]
    ticks.times{
      thisTime += (step / 60.0).minutes
      thisLbl = thisTime.strftime("%a %I:%M")
      rOut << thisLbl + thisTime.strftime("%p").first.downcase
    }
    # return the array
    return rOut
  end

  def self.hours_between
    t1 = @@defaults[:starttime]
    t2 = @@defaults[:endtime]
    hours = []
    k = 0
    t1 = Time.local(t1.year, t1.month, t1.day, t1.hour) #remove minutes to make condition terminate correctly
    t2 = Time.local(t2.year, t2.month, t2.day, t2.hour)
    d = t1
    while(d != t2 && k <= 1000) #fix your condition to round minutes down to the hour for this to be a valid loop terminator
      hours << d
      d += 1.day
      k+=1
    end
    hours.map {|h| Time.local(h.year, h.month, h.day, h.hour)}
  end

  def self.build_gantt_data()
    yield
  end

  def self.all
    gantt = self.build_gantt_data() {
      a = Htop::Htop.obj_system_info#.sort_by {|h| h[:server] }
      a.reduce({}) {|h, row| h.update(row[:server] => [{'duration' => 2, :start_time => row[:time]}]) }
=begin
      hosts = %w{ahlruby1 ahlruby2 ahlruby3 ahlruby4 ahlruby5 ahlruby6 ahlruby7 ahlruby8 ahlruby01 ahlruby02 ahlrpt1 ahlproc1 ahlproc2 ahlsauce1 ahlsauce2 awahl1 awahl2 amruby1 amruby2 amimage1 amimage2 apdf1 apdf2}
      hosts.reduce({}) {|h, server| h.update(server => [{'duration' => 3600, :start_time => (Time.new + ((rand(2)==0)? 2 : -2))}])}
=end

    }
    chart_data = {
      :gantt => gantt,
      :range => [@@defaults[:starttime], @@defaults[:endtime]],
      #:xtics => self.generate_xlabels,#(:starttime => start_time, :endtime => end_time, :ticks => 10),
      :hours => self.hours_between,#(start_time, end_time),
      :size => gantt.keys.size + 1
    }
  end

end

=begin
  start_time = params['dur'].to_i.minutes.ago()
  end_time = Time.now() # or the other parameter which we'll soon edge case here in a moment

  gantt = {
    "Apartments Feed" => Ahl::Task.add_gantt_series("Apartments Feed", start_time, end_time),
    "RentalHomesPlus Feed" => Ahl::Task.add_gantt_series("RentalHomesPlus Feed", start_time, end_time),
    "Backup AHL" => Ahl::Task.add_gantt_series("Backup AHL", start_time, end_time),
    "Defrag AHL" => Ahl::Task.add_gantt_series("Defrag AHL", start_time, end_time),
    "My New Place Feed" => Ahl::Task.add_gantt_series("My New Place Feed", start_time, end_time),
  }
  chart_data = {
    :gantt => gantt,
    :xtics => JS.generate_xlabels(:starttime => start_time, :endtime => end_time, :ticks => 10),
    :hours => hours_between.call(start_time, end_time),
    :size => gantt.keys.size + 1
  }
=end

#Gantt.generate_xlabels
#Gantt.hours_between
=begin
y = {'ahlruby1' => [{
    'duration' => 3600,
    'start_time' => Time.now,
  }]
}
ap y
=end
#a = Htop::Htop.obj_system_info
#a.map {|row| x = { row[:server] => [{'duration' => 3600, :start_time => row[:time]}] } }
#jj a.reduce({}) {|h, row| h.update(row[:server] => [{'duration' => 3600, :start_time => row[:time]}]) }

#ap Gantt.all
