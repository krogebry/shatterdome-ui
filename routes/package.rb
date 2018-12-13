
get '/package' do
  packages = []
  package_files = Dir.glob(File.join('etc', 'packages', '*.yaml'))

  package_files.each do |p_file|
    packages.push(YAML.safe_load(File.read(p_file)))
  end
  erb :package, {:locals => {packages: packages}}
end

get '/package/create' do
  stacks = Shatterdome::Stacks.constants
  erb 'packages/create'.to_sym, {locals: {stacks: stacks}}
end

get '/package/:package_name/launch' do
  LOG.debug('Creating job')
  package_version = '0.1.7'

  package = YAML.safe_load(File.read(File.join('etc', 'packages', "#{params[:package_name]}.yaml")))

  prefix = 'bkroger'

  package['services'].each do |service|
    begin
      job = service.merge( version: package_version )

      job.merge!( prefix: prefix ) unless package['no_prefix']

      worker = Shatterdome::Workers::Stack.new
      worker.send_job(job)
    rescue => e
      LOG.fatal("Unable to queue job: #{e}")
    end
  end

  redirect '/package'
end