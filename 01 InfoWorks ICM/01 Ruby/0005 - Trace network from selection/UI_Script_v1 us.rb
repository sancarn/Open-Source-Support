=begin
	This script will select all objects upstream of the selected objects (links/nodes)
	This technique uses the optimised "all_us_links" navigation provided on `WSLink` objects.
	Note: In some cases Node objects are selected, so we have to navigate to links.
	
	This example also uses the enum_for method which allows you to get Enumerator functionality based on the `WSRowObjectCollection#each` method.

	Remark: Most examples you will find online use the `obj._seen` while doing a static trace.
=end

net = WSApplication.current_network
us_links = net.row_object_collection_selection("_nodes")				# get selected nodes
	.enum_for(:each)                                              # get enumerator for selected nodes
	.map {|node| node.navigate("us_links")}	                      # find us_links of these nodes
	.flatten 																											# Array of arrays to flat array i.e. [[...],[...],...] ==> [...]
selectedLinks = net.row_object_collection_selection("_links")		# get selected links
	.enum_for(:each)																							# get enumerator for selected links
selectedLinks = [us_links,selectedLinks.to_a].flatten           # append selected links to all links us of nodes
selectedLinks.map {|lnk| [lnk.navigate("all_us_links") + lnk]}  # find all links us of all selected links
	.flatten																											# Array of arrays to flat array i.e. [[...],[...],...] ==> [...]
	.each do |lnk|																								# Loop over links and select
		lnk.selected = true
		lnk.us_node.selected = true
	end