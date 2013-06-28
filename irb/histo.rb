

def histo
  h = {
    :mobi => 0,
    :atom => 0,
    :rss => 0,
    :xml => 0,
    :html => 0,
    :none => 0,
  } 
  GoogleSourceStats.where(:confirmed => true).map(&:linked_from).each {|link|
    case(link)
    when /\.mobi$/
      h[:mobi] += 1
    when /\.atom$/
      h[:atom] += 1
    when /\.rss$/
      h[:rss] += 1
    when /\.xml$/
      h[:xml] += 1
    when /\.html$/
      h[:html] += 1
    else
      h[:none] += 1
    end
  }
  ap h
end

