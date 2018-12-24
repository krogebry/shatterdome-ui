
describe "Main routes" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "redirects to login" do
    get '/'
    expect(last_response.status).to eq(302)
  end

  it "Version works" do
    get '/version'
    expect(last_response.status).to eq(200)
    json_response = JSON::parse(last_response.body)

    expect(json_response).to include('shatterdome')
    expect(json_response['shatterdome']).to eq(Shatterdome::VERSION)

    expect(json_response).to include('shatterdome_ui')
    expect(json_response['shatterdome_ui']).to eq(ShatterdomeUI::VERSION)

    # expect(json_response).to include('shatterdome_worker')
    # expect(json_response['shatterdome_worker']).to eq(ShatterdomeWorker::VERSION)
  end

  it "returns the correct information for health checking" do
    get '/healthz'
    expect(last_response.status).to eq(200)
    json_response = JSON::parse(last_response.body)
    expect(json_response).to include('success')
    expect(json_response['success']).to eq(true)
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

