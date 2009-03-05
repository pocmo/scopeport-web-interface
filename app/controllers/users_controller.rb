class UsersController < ApplicationController

	before_filter :permission?, :except => [:settings, :saveusersettings]

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
 
  def create
    # Is this the first admin user form?
    if User.find(:all).size == 0
      @first_admin = true
    else
      @first_admin = false
    end

    @departments = Department.find :all
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      if @first_admin == true
        redirect_to :controller => "sessions", :action => "new"
        flash[:notice] = "User has been created. You can login now!"
      else
        redirect_to :action => "index"
        flash[:notice] = "User created."
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
		if User.find(params[:id]).destroy
			flash[:notice] = "User deleted successfully."
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

    # ONly allow admins to change the admin flag.
    params[:user][:admin] = false unless current_user.admin

		if @user.update_attributes(params[:user])
			 flash[:notice] = "User profile updated successfully."
			 redirect_to :action => "index"
		else
		 	flash[:error] = "An error has occurred."
		 	render :action => :edit, :id => params[:id]
		end
	end

  def createdepartment
    @department = Department.new params[:department]
    if @department.save
      flash[:notice] = "Department has been added."
    else
      flash[:error] = "Could not add department! Make sure to fill out the name field."
    end
    redirect_to :action => "index"
  end

  def deletedepartment
    department = Department.find params[:id]
    if department.destroy
      flash[:notice] = "Department has been deleted."
    else
      flash[:error] = "Could not delete department!"
    end
    redirect_to :action => "index"
  end

end
