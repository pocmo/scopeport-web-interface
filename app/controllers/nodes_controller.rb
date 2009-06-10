class NodesController < ApplicationController
  def index
    @nodes = Node.find :all

    @new_node = Node.new
    @name_suggestion = "ScopePort Node 1"
    if Node.count > 0
      @name_suggestion = "ScopePort Node #{Node.last.id+1}"
    end

    @settings = Setting.find :last
    @cloud_pass = ""
    unless @settings.blank?
      @cloud_pass = @settings.cloud_master_password
    end

  end

  def new
    @new_node = Node.new params[:new_node]
    if @new_node.save
      flash[:notice] = "Node has been added."
      log("added", "a node")
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
      log("edited", "a node", @node.id)
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
      log("deleted", "a node", node.name)
    else
      flash[:error] = "Could not destroy node."
    end
    redirect_to :action => "index"
  end

  def setpass
    require 'md5'
    params[:cloud_settings][:cloud_master_password] = MD5.new(params[:cloud_settings][:cloud_master_password]).to_s
    if Setting.count > 0
      settings = Setting.update :last, params[:cloud_settings]
    else
      settings = Setting.new params[:cloud_settings]
    end
    if settings.save
      flash[:notice] = "Master password has been changed!"
    else
      flash[:error] = "Could not change master password."
    end
    redirect_to :action => "index"
  end

end
