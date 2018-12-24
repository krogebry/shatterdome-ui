
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

    stacks.push(
        description: desc,
        stack_class_name: stack_class_name
    )
  end

  locals = {
      stacks: stacks
  }

  if params.has_key?('saved_launch')
    locals[:params] = DB['saved_launches'].find(_id: BSON::ObjectId(params['saved_launch'])).first
  end

  erb 'stack/create'.to_sym, locals: locals
end

post '/stack/create' do
  # pp params

  config = {}

  if params.has_key?('network')
    config['network'] = {
        vpc: {
            Name: params['network']
        },
        subnet: params['subnet']
    }
  end

  # Specific hook for ECSService.
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
        code: params['health_check_code']
    }

    config['environment'] = {}
    params['env_key'].each do |i, key|
      config['environment'][key] = params['env_val'][i]
    end

    config['cpu'] = 1024
    config['num'] = 1
    config['mem'] = 500

    config['name'] = params['stack_name']

    config['image'] = {
        name: params['image'],
        label: params['label']
    }

    stack = Shatterdome.get_stack_by_name(params['cluster'])
    config['cluster_name'] = stack['tags'].select {|t| t['key'] == 'Name'}.first['value']
    config['cluster_version'] = stack['tags'].select {|t| t['key'] == 'Version'}.first['value']
  end

  if params['stack_type'] == 'OpenVPN'
    config['ami'] = {Version: params['ami']}
  end

  config['capacity'] = {min: 1, max: 1, desired: 1}

  config['capacity']['type'] = case params['stack_size']
                               when 'small'
                                 't2.micro'
                               when 'medium'
                                 't2.large'
                               when 'large'
                                 'c4.large'
                               end

  # pp config

  job = {
      name: params['stack_name'],
      type: params['stack_type'],
      size: params['stack_size'],
      config: config,
      version: params['stack_version']
  }

  worker = ShatterdomeWorker::Workers::Stack.new
  job_id = worker.send_job(job)

  erb 'stack/create_complete'.to_sym, {locals: {message_id: job_id}}
end

get '/stack/:stack_name' do
  stack = Shatterdome.get_stack_by_name(params[:stack_name])
  cost_per_hour = 0.0116
  erb 'stack/view'.to_sym, {locals: {stack: stack, cost_per_hour: cost_per_hour}}
end

post '/stack/:stack_name/scale' do
  pp params
  stack = Shatterdome::get_stack_by_name(params[:stack_name])
  # pp stack
  stack_tag_name = stack['tags'].select{|t| t['key'] == 'Name'}.first['value']
  stack_tag_version = stack['tags'].select{|t| t['key'] == 'Version'}.first['value']

  stack = Shatterdome::Stacks::GenericASG.new(stack_tag_name, stack_tag_version)
  LOG.info("ASG: #{params[:asg_min]}/#{params[:asg_max]}/#{params[:asg_desired]}")
  stack.scale(params[:asg_min], params[:asg_max], params[:asg_desired])

  {p: @params}.to_json
end