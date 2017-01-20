require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  
  test 'should get index page' do
    get :index
    assert_response :success
    assert_template 'index', layout: nil
  end
end