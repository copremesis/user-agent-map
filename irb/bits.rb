


class Foo
  def show(index)
    puts ['method', index].join(':')
  end
end

foo = Foo.new

method = foo.method(:show)

#(0..1).each(&blah)

#method.call(0)
