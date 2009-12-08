module HostsHelper

  def showGraphDummy name, host_id, graph_days, token, title = ""
    image_tag "blurred_graphs/#{name}.png", :id => "graph-#{name}-blurred", :style => "cursor: pointer;", :onclick => "showGraph('#{name}', '#{host_id}', '#{graph_days}', '#{token}')", :title => title
  end

end
