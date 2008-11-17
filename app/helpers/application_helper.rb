# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

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
		return link_to name, { :controller => section }, :class => cssclass
	end

	# Displays the last log message.
	def displayLastLogMessage
		return @lastLogMessage
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
		case type
			when "email"
				return image_tag "icons/email.png", { :style => style }
			when "xmpp"
				return image_tag "icons/xmpp.png", { :style => style }
			when "mobilec"
				return image_tag "icons/mobilec.png", { :style => style }
			when "delete"
				return image_tag "icons/delete.png", { :style => style }
		end
		return
	end

	# Returns the CSS class that represents the colors of an service state.
	def getErrorStyle sensorState
		case sensorState
			when 0:
				return "sensor-error"
			when 1:
				return "sensor-okay"
			when 2:
				return "sensor-warn"
		end
		return "sensor-none"
	end

	# Returns a descriptive name for a service state.
	def getErrorName sensorState
		case sensorState
			when 0:
				return "Error. Service not reachable or speaking wrong protocol."
			when 1:
				return "Okay. No errors reported."
			when 2:
				return "Warning. Too high response time."
		end
		return "sensor-none"
	end

end
