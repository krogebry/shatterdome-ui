describe "API interactions" do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  before do
    post '/auth/login', {email: 'bryan.kroger@edos.io', password: 'blah'}
    test_stack = {
        stack_name: 'test_stack1',
        owner: 'owner',
        stack_status: 'CREATE_COMPLETE',
        type: 'type'
    }
    @test_stack = JSON::parse(test_stack.to_json)
  end

  it "Should return a list of stacks" do
    allow(Shatterdome).to receive(:get_stacks).and_return([@test_stack])

    get "/api/1.0/stacks"
    expect(last_response.status).to eq(200)

    res = JSON.parse(last_response.body)
    expect(res).to eq({'data' => [@test_stack]})
  end

  it "Should return the correct OpenVPN elements" do
    images = JSON::parse(File.read(File.join('spec', 'fixtures', 'amis.json')))['images']
    allow(Shatterdome).to receive(:get_amis).and_return(images)

    get "/api/1.0/stack/elements/OpenVPN"
    expect(last_response.status).to eq(200)

    body = JSON::parse(last_response.body)

    expect(body['content']).to match(/id="network"/)
    expect(body['content']).to match(/id="ami"/)
  end

end