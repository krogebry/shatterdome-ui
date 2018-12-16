
describe "Main routes" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "redirects to login" do
    get '/'
    expect(last_response.status).to eq(302)
  end

  it "show the proper login page" do
    get '/auth/login'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Manager Login')
  end

end

describe "Authenticated pages" do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  before do
    post '/auth/login', {email: 'bryan.kroger@edos.io', password: 'blah'}
  end

  it "should show main page when logged in" do
    get '/'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Cloud Manager')
  end

  it "should show main page when logged in" do
    get '/'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('Cloud Manager')
  end
end


