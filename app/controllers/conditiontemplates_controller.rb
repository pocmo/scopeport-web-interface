class ConditiontemplatesController < ApplicationController
  def index
    @templates = Conditiontemplate.find :all
    @new_template = Conditiontemplate.new
  end

  def create
    template = Conditiontemplate.new params[:new_template]
    if template.save
      flash[:notice] = "Condition template has been added!"
      redirect_to :action => :show, :id => template.id
    else
      flash[:error] = "Could not add condition template."
      redirect_to :action => :index
    end
  end

  def show
    @ct = Conditiontemplate.find params[:id]
    @conditions = Hash.new

    sensors = Host::getSensors
    sensors.each do |sensor|
      @conditions[sensor] = Conditiontemplatevalue.find_by_conditiontemplate_id_and_sensor params[:id], sensor
    end
  end
  
  def update
    template = Conditiontemplate.find params[:id]
    redirect_to :controller => "overview" if params[:id].blank? or template.blank?

    if params[:conditions].blank? or params[:operators].blank?
      flash[:error] = "Could not save template: Missing parameters."
      redirect_to :action => "show", :id => params[:id]
    end

    # We got all needed parameters
    params[:conditions].each do |name, condition|
      # Is a valid operator set?
      next if params[:operators][name].blank? or !validOperator? params[:operators][name] or name.blank? or condition.blank? 
      
      # Does the condition already exist?
      cd = Conditiontemplatevalue.find_by_conditiontemplate_id_and_sensor params[:id], name
      cd = Conditiontemplatevalue.new if cd.blank?
      cd.conditiontemplate_id = params[:id]
      cd.sensor = name
      cd.operator = params[:operators][name]
      cd.value = condition
      cd.save
    end
    flash[:notice] = "The template has been saved"
    log("changed", "condition template", [template.name, template.id])
    redirect_to :action => "show", :id => params[:id]
  end

  private

  def validOperator? operator
    return true if operator == "<"
    return true if operator == ">"
    return true if operator == "="
    return false
  end

end
