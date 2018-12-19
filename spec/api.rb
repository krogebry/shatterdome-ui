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

  it "Should flush the cache" do
    get "/api/1.0/flush_cache"
    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res).to include('success')
    expect(res['success']).to eq(true)
  end

  it "Should return a list of stacks" do
    allow(Shatterdome).to receive(:get_stacks).and_return([@test_stack])

    get "/api/1.0/stacks"
    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res).to eq({'data' => [@test_stack]})
  end


  it 'should return saved launches ' do
    get '/api/1.0/launch_configs'
    expect(last_response.status).to eq(200)
    json = JSON::parse(last_response.body)
    expect(json['success']).to eq(true)
  end

  describe "Saved launch workflow" do
    before do
      @launch_config = JSON::parse(File.read(File.join('spec', 'fixtures', 'launch_config.json')))
    end

    it 'should save a launch config' do
      post '/api/1.0/launch_config', @launch_config
      expect(last_response.status).to eq(200)
    end

    it 'should return the launch config from the api' do
      get '/api/1.0/launch_configs'
      expect(last_response.status).to eq(200)
      json = JSON::parse(last_response.body)
      expect(json['success']).to eq(true)
      expect(json['data'].size).to eq(1)

      expect(json['data'][0]).to include('stack_name')
      expect(json['data'][0]['stack_name']).to eq(@launch_config['stack_name'])

      expect(json['data'][0]).to include('launch_name')
      expect(json['data'][0]['launch_name']).to eq(@launch_config['launch_name'])
    end

    it 'should upsert the launch_config with a simple change' do
      new_launch_config = @launch_config.clone
      new_launch_config['ami'] = '0.1.5'
      post '/api/1.0/launch_config', new_launch_config
      expect(last_response.status).to eq(200)
      json = JSON::parse(last_response.body)
      expect(json['success']).to eq(true)

      get '/api/1.0/launch_configs'
      expect(last_response.status).to eq(200)
      json = JSON::parse(last_response.body)

      expect(json['data'].size).to eq(1)

      expect(json['data'][0]).to include('stack_name')
      expect(json['data'][0]['stack_name']).to eq(new_launch_config['stack_name'])

      expect(json['data'][0]).to include('ami')
      expect(json['data'][0]['ami']).to eq(new_launch_config['ami'])
      expect(json['data'][0]['ami']).not_to eq(@launch_config['ami'])

      expect(json['data'][0]).to include('launch_name')
      expect(json['data'][0]['launch_name']).to eq(new_launch_config['launch_name'])
    end

    it "should return a specific config from the api" do
      get '/api/1.0/launch_configs'
      expect(last_response.status).to eq(200)
      json = JSON::parse(last_response.body)

      get "/api/1.0/launch_config/#{json['data'][0]['_id']}"
      expect(last_response.status).to eq(200)
      json = JSON::parse(last_response.body)
      expect(json['data']['stack_name']).to eq(@launch_config['stack_name'])
    end
  end

  describe "API dynamic element generation" do
    it "Should return the correct ECSService elements" do
      hosted_zones = JSON::parse(File.read(File.join('spec', 'fixtures', 'hosted_zones.json')))
      allow(Shatterdome).to receive(:get_hosted_zones).and_return(hosted_zones)

      cluster_stacks = JSON::parse(File.read(File.join('spec', 'fixtures', 'ecs_cluster_stacks.json')))
      allow(Shatterdome).to receive(:get_stacks).and_return(cluster_stacks)

      get "/api/1.0/stack/elements/ECSService"
      expect(last_response.status).to eq(200)

      body = JSON::parse(last_response.body)

      expect(body['content']).to match(/id="cluster"/)
      expect(body['content']).to match(/id="dns_domain"/)
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

end