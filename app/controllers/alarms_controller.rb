class AlarmsController < ApplicationController
	def index
		@service_alarms = Alarm.find_all_by_alarm_type(2,
																:select => "alarms.id, alarms.timestamp, alarms.status, services.name AS servicename",
																:joins => "LEFT JOIN services ON services.id = alarms.serviceid")
	end
end
