module AlarmsHelper
	# Returns the status message of an alarm.
	def getAlarmStatus status, colored = false
		# Build a standard message.
		if colored == true
			message = "<span class='sensor-error-text'>New/Unattended</span>"
		else
			message = "New/Unattended"
		end
		
		# Return standard message if status is blank.
		return message if status == false
		
		# Change the message if the status equals 1.
		if status == true
			if colored == true
				message = "<span class='sensor-okay-text'>Okay/Attended</span>"
			else
				message = "Okay/Attended"
			end
		end

		# Return the message
		return message
	end

	def getAlarmStatusBackgroundClass status
		return "sensor-error" if status.nil? or status == false
		return "sensor-okay"
	end

	# Returns the alarm message of a service.
	def getServiceAlarmMessage status, ms
		return "Unknown" if status.nil? or ms.nil?

		return "The service could not be reached" if status == 0
		return "The service had a too high response time (#{ms} ms)" if status == 2
    return "The service timed out" if status == 4
    return "Unknown"
	end

  def updateAlarmStatusAJAX id, status
    return "" if id.blank?

    if status == false or status.blank?
      action = "attend"
    else
      action = "unattend"
    end

    return (remote_function :url => { :action => action, :id => id }) + "; updateAlarmRow('#{status}', '#{id}', this);"
  end
	
	#Formats the params to a Array
	def format_filters params
		filter = []
		params.each { |key, value| if Alarm.scopes.has_key? key.to_sym and value != "Any"
															 	 if key == "time" and value != ""
															 	   filter << [key, time_ago_to_f(value.to_f, params['time_unit'])]
															 	 else
															 	   filter << [key, value]
															 	 end
															 end }
		
		return filter
	end
	
	#Calls recursively the methods (scopes) from Alarm
	def call_scopes(alarm, *args)
		args = args.first
		if !args[0].is_a? Array	
			return args
		else
			returned = call_scopes(alarm, args.slice(-1))
			return alarm.send(args[0][0], args[0][1]).send(returned[0], returned[1])	
		end
	end
	
	#Creates all filters used in partial "_filters"
	def generate_filters
		filters = {}
		
		filters['users'] = User.find(:all, :order => "login").collect { |p| "<option value=#{p.id}>#{p.login}</option>"  }
		filters['users'].insert(0, "<option>Any</option>")
		
		filters['services'] = Service.find(:all, :order => "name").collect { |p| "<option value=#{p.id}>#{p.name}</option>" }
		filters['services'].insert(0, "<option>Any</option>")
		
		filters['service_groups'] = Servicegroup.find(:all, :order => "name").collect { |p| "<option value=#{p.id}>#{p.name}</option>" }
		filters['service_groups'].insert(0, "<option>Any</option>")
		
		filters['time_unit'] = generate_dropbox('minutes', 'hours', 'days', 'weeks', 'months')
		
		filters['status'] = ["<option>Any</option>", "<option value = 1>Attended</option>", "<option value = 0>Not Attended</option>"]
		
		filters['service_state'] = ["<option>Any</option>", "<option value = 0>Not reached</option>", "<option value = 2>Too high response time</option>", "<option value = 4>Timeout</option>"]
		
		custom_f = ["None"]
		current_user.custom_filters.each { |cf| custom_f << cf.name}
		filters['custom_filters'] = generate_dropbox(custom_f)
		
		return filters
	end
	
	#Automates a simple dropbox with just a list of options without values
	def generate_dropbox(*args)
		options = []
		args = args[0] if args[0].is_a? Array
		args.each { |p| options << "<option>#{p}</option>"}
		return options
	end
	
	#Returns "2 days ago" in seconds
	def time_ago_to_f(value, unit)
		value.send(unit).ago.to_f
	end
	
	#Returns a string with the filters and parameters used
	def apllied_filters filters
		applied = ""
		filters.each { |f| unless f[0] = "time" and f[1] = ""
											   applied = applied + "| #{f[0]} -> #{f[1]} | "    
											 end }
		return applied
	end
	
end
