net = WSApplication.current_network

#Clear selection
net.clear_selection

#Construct dictionary which links us_node_id and ds_node_id to the links which share them
links = {}
net.row_object_collection('_links').each do |link|
  uid  = link.us_node_id+"."+link.ds_node_id
  (links[uid] ||= []).push(link)
end

#Select where link array length > 1
links.select do |key,value|
  value.length > 1
end.each do |arr|
  arr[1].each do |link|
    link.selected = true
  end
end
