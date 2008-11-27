module AlarmsHelper
	def getAlarmStatus status
		return "New/Unattended" if status.blank?
		case status
			when 0:
				return "New Unattended"
			when 1:
				return "Okay/Attended"
		end
		return "New/Unattended"
	end
end
