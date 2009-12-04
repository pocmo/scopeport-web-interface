class UsersController < ApplicationController

	before_filter(:except => [:settings, :saveusersettings]) { |controller| controller.block unless controller.permission?}
	
  # Allow to create a first admin user.
  skip_before_filter :login_required, :only => [:new, :create] if User.find(:all).size == 0

  def index
    @users = User.find :all 
    @departments = Department.find :all
    @department = Department.new
  end

  def new
    # Is this the first admin user form?
    if User.find(:all).size == 0
      @first_admin = true
    else
      @first_admin = false
    end

    @user = User.new
    @departments = Department.find :all
  end
 
  def show
    @user = User.find params[:id]
    settings = Setting.find :first

    @user_image = String.new
    unless settings.blank? or !settings.allow_gravatar or !@user.use_gravatar or @user.gravatar_email.blank?
      require "md5"
      email_hash = MD5::md5 @user.gravatar_email
      @user_image = "<img src=\"http://www.gravatar.com/avatar/#{email_hash}?s=80\" alt=\"User avatar\">"
      @with_gravatar = true
    end
  end

  def create
    # Is this the first admin user form?
    if User.find(:all).size == 0
      @first_admin = true
    else
      @first_admin = false
    end

    @departments = Department.find :all
    @user = User.new(params[:user])
    @user.login= params[:user][:login]
    success = @user && @user.save
    if success && @user.errors.empty?
      if @first_admin == true
        redirect_to :controller => "sessions", :action => "new"
        flash[:notice] = "User has been created. You can login now!"
      else
        redirect_to :action => "index"
        flash[:notice] = "User created."
        log("created", "a user", [@user.login, @user.id])
      end
    else
      if @first_admin == true
        flash[:error]  = "Error! Could not set up first administrator account. Please try again.."
      else
        flash[:error]  = "Could not create user!"
      end
      render :action => 'new'
    end
  end
  
  def settings
    @user = User.find current_user.id
    @departments = Department.find :all
    
    settings = Setting.find :first
    if !settings.blank? && settings.allow_gravatar == true
      @gravatar_allowed = true
    else
      @gravatar_allowed = false
    end
  end

  def saveusersettings
    @user = User.update current_user.id, params[:user]

    settings = Setting.find :first
    if !settings.allow_gravatar.blank? && settings.allow_gravatar == true
      @gravatar_allowed = true
    else
      @gravatar_allowed = false
    end

    # Set use_gravatar to false if it is not allowed.
    if @gravatar_allowed == true
      @user.use_gravatar = params[:user][:use_gravatar]
    else
      @user.use_gravatar = false
    end

    if @user.save
      flash[:notice] = "Your settings have been saved."
      redirect_to :action => "settings"
    else
      flash[:error] = "Could not save your settings. Please try again!"
      render :action => "settings"
    end
    
  end

	def delete
		user = User.find(params[:id])
		if user.destroy
			flash[:notice] = "User deleted successfully."
			log("deleted", "a user profile", user.login)
		else
		 	flash[:error] = "An error has occurred."
		end
		
		redirect_to :action => "index"	
	end
	
	def edit
		@user = User.find(params[:id])
		@departments = Department.find :all
	end
	
	def update
		@departments = Department.find :all
		@user = User.find(params[:id])

    # Only admins can change foreign users.
    if params[:id] != current_user.id.to_s && !current_user.admin
      flash[:error] = "Only admins can change foreign users."
		 	render :action => :edit, :id => params[:id]
      return
    end

    # Chaging permissions is not allowed here. This is done in the permissions action.
    params[:user][:admin] = @user.admin
    params[:user][:service_admin] = @user.service_admin

    if @user.update_attributes(params[:user])
		  flash[:notice] = "User profile updated successfully."
		  log("edited", "a user profile", [@user.name, @user.id])
		 	redirect_to :action => :index
		else
		 	flash[:error] = "An error has occurred."
		 	render :action => :edit, :id => params[:id]
		end
	end

  def permissions
    @users = User.find :all
  end

  def set_permission
    # Only admins can do this.
    if current_user.admin != true
      render :text => "no permissions"
      return
    end

    # Check if all required parameters are set.
    if params[:user_id].blank? or params[:type].blank? or params[:old_state].blank?
      render :text => "missing parameters"
      return
    end

    # Fetch the user.
    begin
      user = User.find params[:user_id]
    rescue
      render :text => "user not found"
      return
    end

    case params[:type]
      when "admin"
        if params[:old_state] == "0"
          user.admin = true
        else
          user.admin = false
        end
      when "service_admin"
        if params[:old_state] == "0"
          user.service_admin = true
        else
          user.service_admin = false
        end
      else
        render :text => "invalid type"
        return
    end

    if user.save
      render :nil => true
      return
    else
      render :text => "could not save user"
      return
    end
  end

  def createdepartment
    @department = Department.new params[:department]
    if @department.save
      flash[:notice] = "Department has been added."
      log("created", "a department", [@department.name, @department.id])
    else
      flash[:error] = "Could not add department! Make sure to fill out the name field."
    end
    redirect_to :action => "index"
  end

  def deletedepartment
    department = Department.find params[:id]
    if department.destroy
      flash[:notice] = "Department has been deleted."
      log("deleted", "a department", department.name)
    else
      flash[:error] = "Could not delete department!"
    end
    redirect_to :action => "index"
  end

end
