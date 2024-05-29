require 'rake/testtask'

# Tasks
namespace :agent_monitoring do
  namespace :example do
    desc 'Example Task'
    task task: :environment do
      # Task goes here
    end
  end
end

namespace :db do
  desc "Populate the agents table with sample data"
  task populate_agents: :environment do
    require 'faker'

    50.times do
      Agent.create(
        network: Faker::Internet.ip_v4_address,
        status: %w[active inactive pending].sample,
        agent: Faker::Internet.username,
        host: Faker::Internet.domain_name
      )
    end

    puts "Added 50 sample agents."
  end
end

# Tests
namespace :test do
  desc 'Test AgentMonitoring'
  Rake::TestTask.new(:agent_monitoring) do |t|
    test_dir = File.expand_path('../../test', __dir__)
    t.libs << 'test'
    t.libs << test_dir
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

namespace :agent_monitoring do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_agent_monitoring) do |task|
        task.patterns = ["#{AgentMonitoring::Engine.root}/app/**/*.rb",
                         "#{AgentMonitoring::Engine.root}/lib/**/*.rb",
                         "#{AgentMonitoring::Engine.root}/test/**/*.rb"]
      end
    rescue
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_agent_monitoring'].invoke
  end
end

Rake::Task[:test].enhance ['test:agent_monitoring']

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance ['test:agent_monitoring', 'agent_monitoring:rubocop']
end
