


@x = {}
@t = []
=begin
@t << Thread.new { sleep rand(5); @x[:process1] = 'process 1' }
@t << Thread.new { sleep rand(5); @x[:process2] = 'process 2' }
=end

100.times {|p|
  @t << Thread.new { sleep rand(3); @x["process#{p}".to_sym] = "process #{p}" }
}

=begin
while(@t.reduce(false) {|f, t| f | !!t.status} != false) do
  print "\r#{@x.inspect} #{@t.map(&:status).inspect}"
end
=end
print 'wating...'
@t.map(&:join)

puts 'done';
ap @x




