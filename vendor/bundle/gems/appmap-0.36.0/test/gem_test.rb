#!/usr/bin/env ruby
# frozen_string_literal: true

require 'test_helper'
require 'English'

class MinitestTest < Minitest::Test
  def perform_gem_test(test_name)
    Bundler.with_clean_env do
      Dir.chdir 'test/fixtures/gem_test' do
        FileUtils.rm_rf 'tmp'
        system 'bundle config --local local.appmap ../../..'
        system 'bundle'
        system({ 'APPMAP' => 'true' }, %(bundle exec ruby -Ilib -Itest test/#{test_name}_test.rb))

        yield
      end
    end
  end

  def test_record_gem
    perform_gem_test 'to_param' do
      appmap_file = 'tmp/appmap/minitest/To_param_to_param.appmap.json'
      appmap = JSON.parse(File.read(appmap_file))
      events = appmap['events']
      assert_equal 2, events.size
      assert_equal 'call', events.first['event']
      assert_equal 'to_param', events.first['method_id']
      assert_equal "#{Gem.loaded_specs['activesupport'].gem_dir}/lib/active_support/core_ext/object/to_query.rb", events.first['path']
      assert_equal 'return', events.second['event']
      assert_equal 1, events.second['parent_id']
    end
  end
end
