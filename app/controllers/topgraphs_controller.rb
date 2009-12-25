class TopgraphsController < ApplicationController
  def create
    graph = Topgraph.new params[:topgraph]
    graph.user_id = current_user.id

    if graph.save
      flash[:notice] = "Quick graph has been created."
    else
      flash[:error] = "Could not create quick graph!"
    end
    
    redirect_to :controller => "users", :action => :settings
  end

  def destroy
    graph = Topgraph.find params[:id]

    if graph.delete
      flash[:notice] = "Quick graph has been deleted."
    else
      flash[:error] = "Could not delete quick graph!"
    end
    
    redirect_to :controller => "users", :action => :settings
  end

end
