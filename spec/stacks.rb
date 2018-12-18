
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

  # describe "create openvpn stack" do
  #   before do
  #     # allow(ShatterdomeWorker::Workers::Stack).to receive(:send_job).and_return('job_id')
  #     @stack = JSON::parse(File.read(File.join('spec', 'fixtures', 'openvpn_stack.json')))
  #   end
  #
  #   it "should create the job" do
  #     post '/stack/create', @stack
  #     File.open('/tmp/stack', 'w') do |f|
  #       f.write last_response.body
  #     end
  #     expect(last_response.status).to eq(200)
  #   end
  # end

end

