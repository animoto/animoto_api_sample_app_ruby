require 'test/test_helper'

class EndpointsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_ping 
    get '/ping'
    assert_equal 'pong', last_response.body
    assert_equal 200, last_response.status
  end

  def test_get_index
    get '/'
    assert_match /Photo Album - SunDawg's Little Puppies/, last_response.body
    assert_match /Make Animoto Video/, last_response.body
    assert_equal 200, last_response.status
  end

  def test_post_callbacks
    PartnerApp.expects(:add_callback).once
    ENV['rack.request.form_input'] = 'this is a callback'
    post '/callbacks?transactionToken=123', {}
    assert_equal 201, last_response.status
  end

  def test_get_callbacks
    get '/callbacks'
    assert_equal 200, last_response.status
  end

  def test_get_widget
    get '/widget'
    assert_equal 200, last_response.status
    assert_match /<input type="hidden" name="signature" value="(\w)*"\/>/, last_response.body
    assert_match /<input type="hidden" name="appId" value="#{PartnerApp::Constants::Widget::APP_ID}"\/>/, last_response.body
    assert_match /<input type="hidden" name="partnerId" value="#{PartnerApp::Constants::Partner::PARTNER_ID}"\/>/, last_response.body
  end

  def test_get_play
    mp4 = 'http://some.com/video.mp4'
    get '/play', {'links[file]' => mp4}
    assert_equal 200, last_response.status
    assert_match /#{CGI::escape(mp4)}/, last_response.body
  end

  def test_get_poll
    rendering_job_url = "http://some.com/rendering_job"
    video_url = "http://some.com/video"

    mock_rendering_job = stub('completed?' => true, :video_url => video_url)
    mock_video = stub(:download_url => "http://download.com/url")

    Animoto::Client.any_instance.expects(:find).with(Animoto::RenderingJob, rendering_job_url).once.returns(mock_rendering_job)
    Animoto::Client.any_instance.expects(:find).with(Animoto::Video, video_url).once.returns(mock_video) 
    get '/poll', {:job_url => rendering_job_url}
    assert_equal 200, last_response.status 
    hash = JSON::parse(last_response.body)
    assert hash
    assert_equal true, hash['completed']
    assert_equal "/play?links[file]=" + CGI::escape("http://download.com/url"), hash['url']
  end

  def test_get_finalize
    storyboard_link = "http://some.com/storyboard"
    mock_storyboard = stub
    mock_rendering_manifest = stub
    mock_rendering_job = stub(:url => "http://some.com/url")

    Animoto::Client.any_instance.expects(:find).with(Animoto::Storyboard, storyboard_link).once.returns(mock_storyboard)
    Animoto::RenderingManifest.expects(:new).with(mock_storyboard, :resolution => "480p", :format => "h264", :framerate => 30).once.returns(mock_rendering_manifest)
    Animoto::Client.any_instance.expects('render!').with(mock_rendering_manifest).once.returns(mock_rendering_job) 

    get '/finalize', {'links[storyboard]' => storyboard_link}

    assert_equal 200, last_response.status
    assert_match /job_url=http:\/\/some.com\/url/, last_response.body
  end
end
