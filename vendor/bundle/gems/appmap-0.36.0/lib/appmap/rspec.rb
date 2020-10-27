# frozen_string_literal: true

require 'appmap/util'

module AppMap
  # Integration of AppMap with RSpec. When enabled with APPMAP=true, the AppMap tracer will
  # be activated around each scenario which has the metadata key `:appmap`.
  module RSpec
    APPMAP_OUTPUT_DIR = 'tmp/appmap/rspec'
    LOG = false

    def self.metadata
      AppMap.detect_metadata
    end

    module FeatureAnnotations
      def feature
        return nil unless annotations

        annotations[:feature]
      end

      def labels
        labels = metadata[:appmap]
        if labels.is_a?(Array)
          labels
        elsif labels.is_a?(String) || labels.is_a?(Symbol)
          [ labels ]
        else
          []
        end
      end

      def feature_group
        return nil unless annotations

        annotations[:feature_group]
      end

      def annotations
        metadata.tap do |md|
          description_args_hashes.each do |h|
            md.merge! h
          end
        end
      end

      protected

      def metadata
        return {} unless example_obj.respond_to?(:metadata)

        example_obj.metadata
      end

      def description_args_hashes
        return [] unless example_obj.respond_to?(:metadata)

        (example_obj.metadata[:description_args] || []).select { |arg| arg.is_a?(Hash) }
      end
    end

    # ScopeExample and ScopeExampleGroup is a way to handle the weird way that RSpec
    # stores the nested example names.
    ScopeExample = Struct.new(:example) do
      include FeatureAnnotations

      alias_method :example_obj, :example

      def description?
        true
      end

      def description
        example.description
      end

      def parent
        ScopeExampleGroup.new(example.example_group)
      end
    end

    # As you can see here, the way that RSpec stores the example description and
    # represents the example group hierarchy is pretty weird.
    ScopeExampleGroup = Struct.new(:example_group) do
      include FeatureAnnotations

      alias_method :example_obj, :example_group

      def description_args
        # Don't stringify any hashes that RSpec considers part of the example group description.
        example_group.metadata[:description_args].reject { |arg| arg.is_a?(Hash) }
      end

      def description?
        return true if example_group.respond_to?(:described_class) && example_group.described_class

        return true if example_group.respond_to?(:description) && !description_args.empty?

        false
      end

      def description
        description? ? description_args.join(' ') : nil
      end

      def parent
        # An example group always has a parent; but it might be 'self'...

        # DEPRECATION WARNING: `Module#parent` has been renamed to `module_parent`. `parent` is deprecated and will be
        # removed in Rails 6.1. (called from parent at /Users/kgilpin/source/appland/appmap-ruby/lib/appmap/rspec.rb:110)
        example_group_parent = \
          if example_group.respond_to?(:module_parent)
            example_group.module_parent
          else
            example_group.parent
          end

        example_group_parent != example_group ? ScopeExampleGroup.new(example_group_parent) : nil
      end
    end

    Recording = Struct.new(:example) do
      def initialize(example)
        super

        webdriver_port = lambda do
          return unless defined?(page) && page&.driver

          # This is the ugliest thing ever but I don't want to lose it.
          # All the WebDriver calls are getting app-mapped and it's really unclear
          # what they are.
          page.driver.options[:http_client].instance_variable_get('@server_url').port
        end

        warn "Starting recording of example #{example}" if AppMap::RSpec::LOG
        @trace = AppMap.tracing.trace
        @webdriver_port = webdriver_port.()
      end

      def finish
        warn "Finishing recording of example #{example}" if AppMap::RSpec::LOG

        events = []
        AppMap.tracing.delete @trace

        events << @trace.next_event.to_h while @trace.event?

        AppMap::RSpec.add_event_methods @trace.event_methods

        class_map = AppMap.class_map(@trace.event_methods)

        description = []
        scope = ScopeExample.new(example)
        feature_group = feature = nil

        labels = []
        while scope
          labels += scope.labels
          description << scope.description
          feature ||= scope.feature
          feature_group ||= scope.feature_group
          scope = scope.parent
        end

        labels = labels.map(&:to_s).map(&:strip).reject(&:blank?).map(&:downcase).uniq
        description.reject!(&:nil?).reject!(&:blank?)
        default_description = description.last
        description.reverse!

        normalize = lambda do |desc|
          desc.gsub('it should behave like', '')
              .gsub(/Controller$/, '')
              .gsub(/\s+/, ' ')
              .strip
        end

        full_description = normalize.call(description.join(' '))

        compute_feature_name = lambda do
          return 'unknown' if description.empty?

          feature_description = description.dup
          num_tokens = [2, feature_description.length - 1].min
          feature_description[0...num_tokens].map(&:strip).join(' ')
        end

        feature_group ||= normalize.call(default_description).underscore.gsub('/', '_').humanize
        feature_name = feature || compute_feature_name.call if feature_group
        feature_name = normalize.call(feature_name) if feature_name

        AppMap::RSpec.save full_description,
                           class_map,
                           events: events,
                           feature_name: feature_name,
                           feature_group_name: feature_group,
                           labels: labels.blank? ? nil : labels
      end
    end

    @recordings_by_example = {}
    @event_methods = Set.new

    class << self
      def init
        warn 'Configuring AppMap recorder for RSpec'

        FileUtils.mkdir_p APPMAP_OUTPUT_DIR
      end

      def begin_spec(example)
        @recordings_by_example[example.object_id] = Recording.new(example)
      end

      def end_spec(example)
        recording = @recordings_by_example.delete(example.object_id)
        return warn "No recording found for #{example}" unless recording

        recording.finish
      end

      def config
        @config or raise "AppMap is not configured"
      end

      def add_event_methods(event_methods)
        @event_methods += event_methods
      end

      def save(example_name, class_map, events: nil, feature_name: nil, feature_group_name: nil, labels: nil)
        metadata = AppMap::RSpec.metadata.tap do |m|
          m[:name] = example_name
          m[:app] = AppMap.configuration.name
          m[:feature] = feature_name if feature_name
          m[:feature_group] = feature_group_name if feature_group_name
          m[:labels] = labels if labels
          m[:frameworks] ||= []
          m[:frameworks] << {
            name: 'rspec',
            version: Gem.loaded_specs['rspec-core']&.version&.to_s
          }
          m[:recorder] = {
            name: 'rspec'
          }
        end

        appmap = {
          version: AppMap::APPMAP_FORMAT_VERSION,
          metadata: metadata,
          classMap: class_map,
          events: events
        }.compact
        fname = AppMap::Util.scenario_filename(example_name)

        File.write(File.join(APPMAP_OUTPUT_DIR, fname), JSON.generate(appmap))
      end

      def print_inventory
        class_map = AppMap.class_map(@event_methods)
        save 'Inventory', class_map, labels: %w[inventory]
      end

      def enabled?
        ENV['APPMAP'] == 'true'
      end

      def run
        init
        at_exit do
          print_inventory
        end
      end
    end
  end
end

if AppMap::RSpec.enabled?
  require 'appmap'
  require 'active_support/inflector/transliterate'
  require 'rspec/core'
  require 'rspec/core/example'

  module RSpec
    module Core
      class Example
        class << self
          def wrap_example_block(example, fn)
            proc do
              AppMap::RSpec.begin_spec example
              begin
                instance_exec(&fn)
              ensure
                AppMap::RSpec.end_spec example
              end
            end
          end
        end

        def self.new(*arguments, &block)
          warn "Wrapping example_block for #{name}" if AppMap::RSpec::LOG
          allocate.tap do |obj|
            arguments[arguments.length - 1] = wrap_example_block(obj, arguments.last) if arguments.last.is_a?(Proc)
            obj.send :initialize, *arguments, &block
          end
        end
      end
    end
  end

  AppMap::RSpec.run
end
