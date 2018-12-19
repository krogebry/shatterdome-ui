describe "Unauthenticated stack routes" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "redirects to login" do
    get '/stacks'
    expect(last_response.status).to eq(302)
  end
end

describe "Authenticated stack pages" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before do
    post '/auth/login', {email: 'bryan.kroger@edos.io', password: 'blah'}
  end

  it "returns the create page" do
    get '/stack/create'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match(/action="\/stack\/create"/)
  end
end
