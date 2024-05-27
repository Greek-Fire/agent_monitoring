require File.expand_path('lib/agent_monitoring/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'agent_monitoring'
  s.version     = AgentMonitoring::VERSION
  s.metadata    = { 'is_foreman_plugin' => 'true' }
  s.license     = 'GPL-3.0'
  s.authors     = ['Louis Tiches']
  s.email       = ['ltiches@hallastech.com']
  s.homepage    = 'https://www.hallastech.com'
  s.summary     = 'Monitor Custom agents'
  # also update locale/gemspec.rb
  s.description = 'Create custom agent profiles to monitor performance on hosts'

  s.files = Dir['{app,config,db,lib,locale,webpack}/**/*'] + ['LICENSE', 'Rakefile', 'README.md', 'package.json']

  s.required_ruby_version = '>= 2.7', '< 4'

end
