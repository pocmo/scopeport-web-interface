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
	def getServiceAlarmMessage ms
		return "The service could not be reached" if ms == 0
		return "The service had a too high response time (#{ms} ms)"
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
	
end
