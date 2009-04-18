class AlarmsController < ApplicationController

	before_filter(:except => [:index, :showservicealarm, :attend, :unattend]) { |controller| controller.block unless controller.permission?}

	include AlarmsHelper
	
	def index
		#Here it gets all users, all services, all... to use as a filter
		@filters = generate_filters
		
		@service_alarms = Alarm.paginate :page => params[:page], :order => "alarms.timestamp DESC",
                                :conditions => "alarm_type = 2 AND services.name != ''",
																:select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, services.name AS servicename, alarms.service_state",
																:joins => "LEFT JOIN services ON services.id = alarms.service_id"
  end

	def showservicealarm
    @alarm = Alarm.find params[:id]

    if @alarm.service.blank?
      flash[:error] = "This alarm does not exist."
      redirect_to :controller => "alarms"
      return
    end
    
    if @alarm.service.name.blank?
      flash[:error] = "The service of this alarm does not exist."
      redirect_to :controller => "alarms"
      return
    end
	end

  def attend
    alarm = Alarm.find params[:id]

    if alarm.blank?
      flash[:error] = "This alarm does not exist."
      redirect_to :controller => "alarms"
      return
    end

    # Check if this alarm is already attended.
    if alarm.status == true
      flash[:error] = "This alarm is already attended."
      redirect_to :controller => "alarms"
      return
    end

    # Set last warning time of service to 0.
    unless alarm.service_id.blank?
      service = Service.find_by_id alarm.service_id
      service.lastwarn = 0
      service.save
    end

    # Mark the alarm as "attended".
    alarm.status = 1
    alarm.attendee = current_user.id
    alarm.attendance_date = Time.now

    if alarm.save
      flash[:notice] = "Status changed."
      redirect_to :action => "showservicealarm", :id => params[:id]
    else
      flash[:notice] = "Could not update status! Database error."
      redirect_to :action => "showservicealarm", :id => params[:id]
    end
  end

  def unattend
    alarm = Alarm.find params[:id]

    if alarm.blank?
      flash[:error] = "This alarm does not exist."
      redirect_to :controller => "alarms"
      return
    end

    if alarm.attendee != blank? && alarm.attendee != current_user.id
      flash[:error] = "You don't have the right to mark this alarm as \"New/Unattended\""
      redirect_to :controller => "alarms"
      return
    end

    # Mark the alarm as "unattended".
    alarm.status = 0
    alarm.attendee = nil
    alarm.attendance_date = nil

    if alarm.save
      flash[:notice] = "Status changed."
      redirect_to :action => "showservicealarm", :id => params[:id]
    else
      flash[:notice] = "Could not update status! Database error."
      redirect_to :action => "showservicealarm", :id => params[:id]
    end
  end
  
  def filters
  	formated_filters =	format_filters params
  	db_result = call_scopes(Alarm, formated_filters)
  	p db_result
  	p formated_filters
  	puts db_result.size
  end

end
