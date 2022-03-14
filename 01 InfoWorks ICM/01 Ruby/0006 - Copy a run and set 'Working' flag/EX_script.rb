require "Date"

db=WSApplication.open('',false)
moGroup   = db.model_object_from_type_and_id('Model Group',20)
runObject = db.model_object_from_type_and_id('Run',21)

#Copy existing params from another run object:
network   = runObject['Model Network']
commit_id = runObject['Model Network Commit ID']
events    = runObject.children.enum_for(:each).map {|c| c['Rainfall Event']}.compact.unique
scenarios = runObject.children.enum_for(:each).map {|c| c['NetworkScenarioUID']}.compact.unique
params    = db.list_read_write_run_fields.map {|p| [p, runObject[p]]}.to_h
params['Working'] = true

# put in the things in the hash you want to change here
moGroup.new_run("A whole new run",network,commit_id,events,scenarios,params)