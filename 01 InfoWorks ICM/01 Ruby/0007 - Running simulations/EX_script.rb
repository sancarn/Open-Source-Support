# Open database
databaseFile  = "#{__FILE__}\\..\\2021.1.1_Standalone.icmm"
database      = WSApplication.open databaseFile,false

# Create Run
group = database.model_object('>MODG~Model group')
run   = group.new_run(
	"Run: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")} #{new_guid()}",  # creates a unique name for the run + adds time
	'MODG~Model Group>NNET~Model network',                           # model network to run on
	nil,                                                             # commit ID
	1,                                                               # rainfall event ID (can also use an array of ids/paths/WSModelObject)
	nil,																	                           # scenarios (nil == base)
	{
		'ExitOnFailedInit'         => true,
		'Duration'                 => 14*60,
		'DurationUnit'             => 'Hours',
		'Level'                    => '>MODG~Model group>LEV~Level',
		'ResultsMultiplier'        => 300,
		'TimeStep'                 => 1,
		'StorePRN'                 => true,
		'DontLogModeSwitches'      => false,
		'DontLogRTCRuleChanges'    => false
	}
)

# Select run mode
#		Synchronous Local       - Runs each sim synchronously; 1 sim at a time; waiting for each sim to finish before running the next. Uses local agent.
#   Synchronous Available   - Runs each sim synchronously; 1 sim at a time; waiting for each sim to finish before running the next. Uses any available agent.
#   Asynchronous + Polling  - Runs all sims asynchronously; ruby keeps running and checking sims status
#   Asynchronous + Await    - Runs all sims asynchronously; ruby awaits all jobs
mode="Asynchronous + Polling"
case mode
	when "Asynchronous + Polling"
		sims = run.children.enum_for(:each).to_a
		if WSApplication.connect_local_agent(1)
			handles=WSApplication.launch_sims simsArray,'.',false,0,0
			while sims.any?{|sim| sim.status=='None'}
				puts 'running'
				sleep 1
			end
			puts 'done'
		else
			puts 'Could not connect to local agent'
		end
	when "Asynchronous + Await"
		sims = run.children.enum_for(:each).to_a 
		if WSApplication.connect_local_agent(1)
			handles=WSApplication.launch_sims simsArray,'.',false,0,0
			puts handles
			WSApplication.wait_for_jobs(handles,true,86400000)
			puts 'done'
		else
			puts 'Could not connect to local agent'
		end
	when "Synchronous Local"
		run.children.each do |sim|
			puts 'running sim on local agent'
			sim.run
		end
		puts 'done'
	else #Synchronous MultiAgent
		run.children.each do |sim|
			puts 'running sim'
			sim.run_ex '*',0
		end
		puts 'done'
end


# Additional functions used in the above
BEGIN {
	# Creates a new_guid string to ensure each run is uniquely defined
	def new_guid
		"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx".gsub("x") do
				rand(16).to_s(16)
		end
	end
}