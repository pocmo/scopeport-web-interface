require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  def test_host_index
    get :host, :api_action => "index"
    assert_response :success
  end
  
  def test_host_show
    get :host, :api_action => "show"
    assert_response :success    
  end
  
  def test_service_index
    get :service, :api_action => "index"
    assert_response :success    
  end
  
  def test_service_show
    get :service, :api_action => "show"
    assert_response :success    
  end
  
  def test_alarm_index
    get :alarm, :api_action => "index"
    assert_response :success    
  end
  
  def test_alarm_show
    get :alarm, :api_action => "show"
    assert_response :success    
  end
  
  def test_emergency_index
    get :emergency, :api_action => "index"
    assert_response :success    
  end
  
  def test_emergency_show
    get :emergency, :api_action => "show"
    assert_response :success    
  end
  
  def test_node_index
    get :node, :api_action => "index"
    assert_response :success    
  end
  
  def test_node_show
    get :node, :api_action => "show"
    assert_response :success    
  end
end
