module LogmessagesHelper
	def getNameOfErrorSeverity sev
		case sev
			when 0:
				return "Notice"
			when 1:
				return "Warning"
			when 2:
				return "Critical"
		end
		return "Unknown"
	end
end
