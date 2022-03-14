#LinkWalker
#  Walk procedurally up or down stream.
#  Can be used to build cellular automata.
class LinkWalker
  require 'OStruct'
  attr_accessor :latest, :links, :direction, :meta, :start
  def initialize(latestLink,links,direction,startLink=nil)
    @latest = latestLink
    @links = links
    @direction = direction
    @meta = OpenStruct.new
    
    #Track startLinks
    if startLink==nil
      @start = latestLink
    else
      @start = startLink
    end
  end
  def allLinks()
    return @links + [@latest]
  end
  def next()
    next_node = @latest.navigate(@direction + "_node")[0]
    
    if next_node
      next_links = next_node.navigate(@direction + "_links")
      next_links = next_links.select {|nl| !(self.allLinks.map{|l| l.id}.include?(nl.id))}
      
      return next_links.map do |link|
        next LinkWalker.new(link,@links + [@latest],@direction,@start)
      end
    else
      return []
    end
  end
end


#-------------------------------------------------------------
#dsTraceTilEx(node,&block)   REQUIRES class LinkWalker
#-------------------------------------------------------------
#Trace downstream until a condition is met
#Examples:
#   select ds till you hit a specified manhole id:
#      result = dsTraceTilEx(start_node) {|link| link.ds_node.id == "specific id"}
#   select ds till you hit a pumping station link or no further links:
#      result = dsTraceTilEx(start_node) {|link| link.link_type[/Pmp/i] || link.ds_node.ds_links.length == 0}
#   select ds till tracing distance exceeds 20m
#      result = dsTraceTilEx(start_node) {|link,walker| getLength(walker.allLinks) > 20}
#Use of LinkWalker ensures that tracing tracks which links they pass through
#
def dsTraceTilEx(node,&block)
  #Create walkers for all downstream links
  walkers = []
  node.ds_links.each do |link|
    lw = LinkWalker.new(link,[],"ds")
    lw.meta.alive = true                #set alive flag to be used later during simulation stage
    walkers.push(lw)
  end

  #Like in a cellular automata, run continuously until no cells are alive anymore.
  while walkers.detect {|w| w.meta.alive}
    #Only process living walkers
    alive = walkers.select {|w| w.meta.alive}
    alive.each do |walker|
      #Automatically kill all walkers
      walker.meta.alive = false
      
      #if the block succeeds then set flag to true and stop walking,
      #otherwise continue walking and ensure the next generation are also living.
      #TODO: detect and kill loops
      if block.call(walker.latest,walker)
        walker.meta.flag = true
      else
        nextWalkers = walker.next()
        nextWalkers.each {|w| w.meta.alive = true}
        walkers += nextWalkers
      end
    end
  end
  
  #Return walkers which have matched the criteria
  return walkers.select {|w| w.meta.flag}
end


#-------------------------------------------------------------
#usTraceTilEx(node,&block)   REQUIRES class LinkWalker
#-------------------------------------------------------------
#Trace downstream until a condition is met
#Examples:
#   select us till you hit a specified manhole id:
#      result = usTraceTilEx(start_node) {|link| link.us_node.id == "specific id"}
#   select us till you hit a pumping station link or no further links:
#      result = usTraceTilEx(start_node) {|link| link.link_type[/Pmp/i] || link.us_node.us_links.length == 0}
#   select us till tracing distance exceeds 20m
#      result = usTraceTilEx(start_node) {|link,walker| getLength(walker.allLinks) > 20}
#Use of LinkWalker ensures that tracing tracks which links they pass through
#
def dsTraceTilEx(node,&block)
  #Create walkers for all downstream links
  walkers = []
  node.ds_links.each do |link|
    lw = LinkWalker.new(link,[],"us")
    lw.meta.alive = true
    walkers.push(lw)
  end

  #Like in a cellular automata, run continuously until no cells are alive anymore.
  while walkers.detect {|w| w.meta.alive}
    #Only process living walkers
    alive = walkers.select {|w| w.meta.alive}
    alive.each do |walker|
      #Automatically kill all walkers
      walker.meta.alive = false
      
      #if the block succeeds then set flag to true and stop walking,
      #otherwise continue walking and ensure the next generation are also living.
      #TODO: Detect and kill loops
      if block.call(walker.latest,walker)
        walker.meta.flag = true
      else
        nextWalkers = walker.next()
        nextWalkers.each {|w| w.meta.alive = true}
        walkers += nextWalkers
      end
    end
  end
  
  #Return walkers which have matched the criteria
  return walkers.select {|w| w.meta.flag}
end