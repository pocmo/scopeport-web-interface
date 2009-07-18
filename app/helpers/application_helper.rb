# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

	private
	
	# Shows the standard headline of a page.
	def render_headline headline
		return "<h1>" + headline  + "</h1>"
	end

	# Displays a navigation link and displays if it is currently active
	def navigationLink section, name
		cssclass = "navlink"
		if section.downcase == request.path_parameters["controller"]
			cssclass = "activenavlink"
		end
		return link_to(name, { :controller => section }, :class => cssclass)
	end

	# Returns the possible operating system types.
	def getOSTypes
		return {	"Linux" => "0",
							"FreeBSD" => "0",
							"OpenBSD" => "0" }
	end
	
	# Returns the possible service check protocol types.
	def getServiceTypes
		return {	"None" => "none",
							"HTTP" => "http",
							"SMTP" => "smtp",
							"IMAP" => "imap",
							"POP3" => "pop3",
							"SSH" => "ssh",
							"FTP" => "ftp" }
	end

	# Displays a commonly used icon specified by parameter "type".
	def showIcon type, style=nil
		return image_tag("icons/" + type + ".png", { :style => style })
	end

	# Returns the CSS class that represents the colors of an service state.
	def getErrorStyle sensorState, lastcheck
    # Return "none" if the service has not been checked lately.
    return "none" if Time.at(lastcheck) < 2.minutes.ago

		case sensorState
			when -1:
				return "internal-error"
			when 0:
				return "error"
			when 1:
				return "okay"
			when 2:
				return "warn"
      when 4:
        return "error"
		end
		return "none"
	end

	#Returns the Admin attribute of the current user
	def admin?
		current_user.admin	
	end
	
	def admin_or_service_admin?
		(current_user.admin or current_user.service_admin) 
	end
	
	#Generation time in seconds
	def load_time
		return Time.now - @start_time
	end  
	
		#If there's a new comment, returns a image
	def new_comment_mark
		showIcon("comment", "margin-left: 3px;")
	end
  
end
