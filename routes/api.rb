def api_authenticate
  auth = false

  if session['user']
    auth = true
    LOG.debug(format('Authenticated as: %s', session['user']))
    # elsif params['api_key']
    # LOG.debug(format('Using api key: %s', session['api_key']))
  end

  unless auth
    ## return 503
  end
end



get '/api/1.0/flush_cache' do
  CACHE.flush
  {success: true}.to_json
end

get '/api/1.0/stacks' do
  stacks = Shatterdome.get_stacks({})

  data = []

  stacks.each do |stack|
    data.push(
      stack_name: stack['stack_name'],
      stack_status: stack['stack_status'],
      owner: 'owner',
      type: 'type'
    )
  end

  {data: data}.to_json
end

get '/api/1.0/stack/elements/:stack_type' do
  config = Psych.safe_load(File.read(File.join('etc', 'stacks.yaml')), [], [], true)
  el = config.select {|c| c['type'] == params['stack_type']}.first

  el = {'elements' => []} if el.nil?

  content = ""
  el['elements'].each do |el_name|
    if params['stack_type'] == 'ECSService' && el_name == 'ecs_service'
      zones = Shatterdome.get_hosted_zones['hosted_zones']
      clusters = Shatterdome.get_stacks({Role: 'Cluster'})
      content += erb "stack/elements/#{el_name}".to_sym, {layout: :empty, locals: {clusters: clusters, zones: zones}}

    elsif params['stack_type'] == 'OpenVPN' && el_name == 'openvpn'
      amis = Shatterdome.get_amis({Role: 'OpenVPN'}, {'is-public' => false})
      versions = amis.map {|ami| ami['tags'].select {|t| t['key'] == 'Version'}.first['value']}
      content += erb "stack/elements/#{el_name}".to_sym, {layout: :empty, locals: {versions: versions}}

    else
      content += erb "stack/elements/#{el_name}".to_sym, {layout: :empty}

    end
  end

  content_type 'application/json'
  {success: true, content: content}.to_json
end

require "#{WEB_ROOT}/routes/api/launch_config"
