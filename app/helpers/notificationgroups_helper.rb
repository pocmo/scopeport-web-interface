module NotificationgroupsHelper
	def showNumOfGroupReceivers num
		case num
			when 0
				return "No receivers in this group"
			when 1
				return "One receiver in this group"
		end
		return num.to_s + " receivers in this group"
	end
end
