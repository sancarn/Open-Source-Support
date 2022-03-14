require("./lib/LinkWalker.rb")

net = WSApplication.current_network
pumps = net.row_objects("hw_pump").map do |pmp|
  outfalls = pmp.navigate("all_ds_links").map {|l| l.ds_node}.select {|n| n.type == "Outfall"}
  next {
    :pump => pmp.id,
    :spillWalker => usTraceTilEx(pmp.us_node) do |link|
      (outfalls-link.navigate("all_ds_links").map {|l| l.ds_node}.select {|n| n.type == "Outfall"}).length > 0
    end
  }
end