
describe "Unauthenticated lc routes" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "redirects to login" do
    get '/launch_configs'
    expect(last_response.status).to eq(302)
  end
end

describe "Authenticated lc pages" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before do
    post '/auth/login', {email: 'bryan.kroger@edos.io', password: 'blah'}
  end

  it "returns saved launches page" do
    get '/launch_configs'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match(/id="saved"/)
  end
end

