# frozen_string_literal: true

require 'spec_helper'
require 'open3'

def wait_for_container(app_name)
  start_time = Time.now
  until `docker-compose ps -q --filter health=healthy #{app_name}`.strip != ''
    elapsed = Time.now - start_time
    raise "Timeout waiting for container #{app_name} to be ready" if elapsed > 10

    $stderr.write '.' if elapsed > 3
    sleep 0.25
  end
end

def run_cmd(*cmd, &failed)
  out, status = Open3.capture2e(*cmd)
  return [ out, status ] if status.success?

  warn <<~WARNING
    Command failed:
    #{cmd}
    <<< Output:
    #{out}
    >>> End of output
  WARNING
  failed&.call
  raise 'Command failed'
end

shared_context 'Rails app pg database' do
  before(:all) do
    raise 'you must set @fixure_dir' unless @fixture_dir

    print_pg_logs = lambda do
      logs, = run_cmd 'docker-compose logs pg'
      puts "docker-compose logs for pg:"
      puts
      puts logs
    end

    Dir.chdir @fixture_dir do 
      run_cmd 'docker-compose down -v'
      cmd = 'docker-compose up -d pg'
      run_cmd cmd
      wait_for_container 'pg'

      cmd = 'docker-compose run --rm app ./create_app'
      run_cmd cmd, &print_pg_logs
    end
  end

  after(:all) do
    if ENV['NOKILL'] != 'true'
      cmd = 'docker-compose down -v'
      run_cmd cmd, chdir: @fixture_dir
    end
  end
end
