require 'logger'

$LOAD_PATH.push('lib')

LOG = Logger.new STDOUT

require 'shatterdome/tasks/docker'
require 'shatterdome-ui/version'

desc 'Do all of the docker things.'
task :docker do |t,args|
  Rake::Task['docker:build'].invoke('shatterdome-ui', ShatterdomeUI::VERSION )
  Rake::Task['docker:tag'].invoke('shatterdome-ui', ShatterdomeUI::VERSION )
  Rake::Task['docker:push'].invoke('shatterdome-ui', ShatterdomeUI::VERSION )
end