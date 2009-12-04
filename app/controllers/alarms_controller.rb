class AlarmsController < ApplicationController
	
	before_filter(:except => [:index, :showservicealarm, :attend, :unattend, :filter_button, :filters, :customize, :change_values]) { |controller| controller.block unless controller.permission?}

	include AlarmsHelper
	
	def index
		#Here it gets all users, all services, all... to use as a filter
		@filters = generate_filters
		
		@service_alarms = Alarm.paginate :page => params[:page], :order => "alarms.timestamp DESC",
                                :conditions => "alarm_type = 2 AND services.name != ''",
																:select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, services.name AS servicename, alarms.service_state",
																:joins => "LEFT JOIN services ON services.id = alarms.service_id"
		
    @host_alarms = Alarm.paginate :page => params[:page], :order => "alarms.timestamp DESC",
                                :conditions => "alarm_type = 1 AND hosts.name != ''",
																:select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, alarms.sensor, alarms.value, hosts.name AS hostname",
																:joins => "LEFT JOIN hosts ON hosts.id = alarms.host_id"
  end

	def showservicealarm
    @alarm = Alarm.find params[:id]
    @service = Service.find @alarm.service_id

    if @alarm.blank? or @service.blank?
      flash[:error] = "This alarm does not exist."
      redirect_to :controller => "alarms"
      return
    end
    
    if @service.name.blank?
      flash[:error] = "The service of this alarm does not exist."
      redirect_to :controller => "alarms"
      return
    end
	end

	def showhostalarm
    @alarm = Alarm.find params[:id]
    @host = Host.find @alarm.host_id

    if @alarm.blank? or @host.blank?
      flash[:error] = "This alarm does not exist."
      redirect_to :controller => "alarms"
      return
    end
    
    if @host.name.blank?
      flash[:error] = "The host of this alarm does not exist."
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
    if alarm.alarm_type == 1
      unless alarm.host_id.blank? or alarm.sensor.blank? or Host::longToShortSensorName(alarm.sensor).blank?
        sensor = Sensorcondition.find_by_host_id_and_sensor alarm.host_id, Host::longToShortSensorName(alarm.sensor)
        sensor.last_warning = 0
        sensor.save
      end
    else
      unless alarm.service_id.blank?
        service = Service.find_by_id alarm.service_id
        service.lastwarn = 0
        service.save
      end
    end

    # Mark the alarm as "attended".
    alarm.status = 1
    alarm.attendee = current_user.id
    alarm.attendance_date = Time.now

    if alarm.save
      flash[:notice] = "Status changed."
    else
      flash[:notice] = "Could not update status! Database error."
    end

    if alarm.alarm_type == 1
      redirect_to :action => "showhostalarm", :id => params[:id]
    else
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
    else
      flash[:notice] = "Could not update status! Database error."
    end
    
    if alarm.alarm_type == 1
      redirect_to :action => "showhostalarm", :id => params[:id]
    else
      redirect_to :action => "showservicealarm", :id => params[:id]
    end
  end
  
  def filters
  	@formated_filters =	format_filters session[:params]
  	db_result = call_scopes(Alarm, @formated_filters)
  	@service_alarms = db_result.paginate :page => params[:page], :order => "alarms.timestamp DESC",
                                :conditions => "alarm_type = 2 AND services.name != ''",
																:select => "alarms.id, alarms.timestamp, alarms.status, alarms.ms, alarms.attendee, services.name AS servicename, alarms.service_state",
																:joins => "LEFT JOIN services ON services.id = alarms.service_id"
  	
  	@filters = generate_filters
  	render :controller => "alarms", :action => "index"
  	
  end
  
  def customize
  	params = session[:params]
  	filters = format_filters params
  	#We need to know the exact input of: time unit and the time
  	filters << ["time_unit", params["time_unit"]]
  	filters << ["time_ago", params["time"]]
  	
  	custom_filter = CustomFilter.new(:name => params[:name], :filters => filters, :user_id => current_user.id)
  	
  	if custom_filter.save
  		flash[:notice] = "Custom Filter created."
  	else
  		flash[:error]  = "Could not create custom Filter!"
  	end
  	
  	redirect_to :action => :index
  end
  
  def filter_button
  	session[:params] = params
  	if params[:commit] == "Filter"
  		redirect_to :action => "filters"
  	elsif params[:commit] == "Save Filter"
  		redirect_to :action => :customize
  	elsif params[:commit] == "Delete"
  		redirect_to :action => :delete_filter
  	end
  end
	
	def change_values
		@filters_set = CustomFilter.find_by_name(params['custom_filter']).to_json
		respond_to do |format|
			format.js
		end
	end
	
	def store_comment
    comment = Alarmcomment.new params[:new_comment]

    alarm_id = params[:new_comment][:alarm_id]
    user_id = current_user.id
    alarm_type = params[:misc][:alarm_type]

    if alarm_id.blank? or user_id.blank? or alarm_type.blank?
      flash[:error] = "Could not add comment: Missing parameters."
      redirect_to :action => "index"
      return
    end

    comment.alarm_id = alarm_id
    comment.user_id = user_id

    if comment.save
      flash[:notice] = "Comment has been added."
      log("commented", "on a alarm", comment.alarm_id)
    else
      flash[:error] = "Could not add comment! Please fill out all fields."
    end

    if alarm_type == "1"
      redirect_to :action => "showhostalarm", :id => alarm_id
    else
      redirect_to :action => "showservicealarm", :id => alarm_id
    end
  end
  
  def deletecomment
    comment = Alarmcomment.find params[:id]
    if comment.nil?
      render :text => "Comment not found"
      return
    end
    
    if comment.user_id == current_user.id
      if comment.destroy
        render :text => "Comment deleted."
      else
        render :text => "Could not delete comment."
      end
      return
    end

    render :text => "This is not your comment."
  end
  
  def delete_filter
  	
  end
end
