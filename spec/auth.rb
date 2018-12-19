
describe "Authentication workflow" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "show the proper login page" do
    get '/auth/login'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Manager Login')
  end

  it "logout will clear session and redirect" do
    get '/auth/logout'
    expect(last_response.status).to eq(302)
    expect(last_response.header['Location']).to match(/\/auth\/login/)
  end

  it "should fail to login with bad creds" do
    post '/auth/login', {}
    expect(last_response.status).to eq(302)
    expect(last_response.header['Location']).to eq('http://example.org/auth/login?auth_failed')
  end
end
