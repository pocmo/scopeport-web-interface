class UsersController < ApplicationController
  # Allow to create a first admin user.
  skip_before_filter :login_required if User.find(:all).size == 0

  # render new.rhtml
  def new
    # Is this the first admin user form?
    if User.find(:all).size == 0
      @first_admin = true
    else
      @first_admin = false
    end

    @user = User.new
  end
 
  def create
    # Is this the first admin user form?
    if User.find(:all).size == 0
      @first_admin = true
    else
      @first_admin = false
    end

    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      if @first_admin == true
        redirect_to :controller => "sessions", :action => "new"
        flash[:notice] = "User has been created. You can login now!"
      else
        redirect_back_or_default('/')
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
end
