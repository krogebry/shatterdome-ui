get '/stacks' do
  erb :stacks
end

get '/stack/create/ecs_service' do
  ## Active ECS stacks
  stacks = Shatterdome::get_stacks({Role: 'Cluster'})

  erb 'stack/create_ecs_service'.to_sym, {locals: {stacks: stacks}}
end

get '/stack/create' do
  stacks = []

  exclude_stacks = %i(Network Bastion ServiceGroup GenericASG)

  Shatterdome::Stacks.constants.select {|c|
    c unless c.match(/Exception/)
  }.select {|c|
    c unless exclude_stacks.include?(c)
  }.each do |stack_class_name|
    begin
      desc = Shatterdome::Stacks.const_get(stack_class_name)::DESCRIPTION
    rescue NameError
      desc = "No description"
    end

    stacks.push({
                    description: desc,
                    stack_class_name: stack_class_name
                })
  end

  erb 'stack/create'.to_sym, {locals: {stacks: stacks}}
end

post '/stack/create' do
  pp params

  config = {}

  if params.has_key?('network')
    config['network'] = {
      vpc: {
          Name: params['network']
      },
      subnet: params['subnet']
    }
  end

  if params.has_key?('port')
    config['dns'] = {
        name: params['dns'],
        hosted_zone_name: params['dns_domain']
    }
    config['cluster'] = params['cluster']
    config['public'] = params['public']
    config['ports'] = [params['port'].to_i]
    config['health_check'] = {
      url: params['health_check_url'],
      code: params['health_check_port']
    }

    # cpu: 1024
    # num: 1
    # mem: 500

    config['cpu'] = 1024
    config['num'] = 1
    config['mem'] = 500

    config['name'] = params['stack_name']

    config['image'] = {
        name: params['image'],
        label: params['label']
    }

    stack = Shatterdome.get_stack_by_name(params['cluster'])
    # pp params['cluster'].scan(/$(.*)-([0-9]-[0-9]-[0-9])^/)[0]
    # (cluster_name, cluster_version) = params['cluster'].scan(/$(.*)-([0-9]-[0-9]-[0-9])^/)[0]
    config['cluster_name'] = stack['tags'].select{|t| t['key'] == 'Name' }.first['value']
    config['cluster_version'] = stack['tags'].select{|t| t['key'] == 'Version' }.first['value']
  end

  # begin
  #   unless params['config'].empty?
  #     config = YAML.safe_load(params['config'])
  #   end
  # rescue => e
  #   LOG.fatal("Unable to parse config: #{e}")
  # end

  job = {
      name: params['stack_name'],
      type: params['stack_type'],
      size: params['stack_size'],
      config: config,
      version: params['stack_version']
  }
  pp job

  queue_url = "https://sqs.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_ACCOUNT_ID']}/shatterdome_stacks"
  @client = Shatterdome.get_client('sqs')
  resp = @client.send_message({
                                  queue_url: queue_url,
                                  message_body: job.to_json,
                                  delay_seconds: 1
                              })

  message_id = resp.message_id

  erb 'stack/create_complete'.to_sym, {locals: { message_id: message_id }}
end