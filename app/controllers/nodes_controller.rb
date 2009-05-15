class NodesController < ApplicationController
  def index
    @nodes = Node.find :all

    @new_node = Node.new
    @name_suggestion = "ScopePort Node 1"
    if Node.count > 0
      @name_suggestion = "ScopePort Node #{Node.last.id+1}"
    end

    @cloud_pass = Setting.find(:last).cloud_master_password

  end

  def new
    @new_node = Node.new params[:new_node]
    if @new_node.save
      flash[:notice] = "Node has been added."
    else
      flash[:error] = "Could not add node!"
    end
    redirect_to :action => "index"
  end

  def edit
    @node = Node.find params[:id]
  end
  
  def update
    @node = Node.update params[:id], params[:node]
    if @node.save
      flash[:notice] = "Node has been changed."
      redirect_to :action => "index"
    else
      flash[:error] = "Could not change node!"
      render :action => "edit"
    end
  end

  def destroy
    node = Node.find params[:destroy_node][:node]
    if node.destroy
      flash[:notice] = "Node has been destroyed!"
    else
      flash[:error] = "Could not destroy node."
    end
    redirect_to :action => "index"
  end

  def setpass
    require 'md5'
    params[:cloud_settings][:cloud_master_password] = MD5.new(params[:cloud_settings][:cloud_master_password]).to_s
    settings = Setting.update :last, params[:cloud_settings]
    if settings.save
      flash[:notice] = "Master password has been changed!"
    else
      flash[:error] = "Could not change master password."
    end
    redirect_to :action => "index"
  end

end
