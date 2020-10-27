# frozen_string_literal: true

module AppMap
  class Config
    Package = Struct.new(:path, :gem, :package_name, :exclude, :labels) do
      class << self
        def build_from_path(path, package_name: nil, exclude: [], labels: [])
          Package.new(path, nil, package_name, exclude, labels)
        end

        def build_from_gem(gem, package_name: nil, exclude: [], labels: [])
          gem_paths(gem).map do |gem_path|
            Package.new(gem_path, gem, package_name, exclude, labels)
          end
        end

        private_class_method :new

        protected

        def gem_paths(gem)
          gemspec = Gem.loaded_specs[gem] or raise "Gem #{gem.inspect} not found"
          gemspec.source_paths.map do |path|
            File.join(gemspec.gem_dir, path)
          end
        end
      end

      def name
        gem || path
      end

      def to_h
        {
          path: path,
          package_name: package_name,
          gem: gem,
          exclude: exclude.blank? ? nil : exclude,
          labels: labels.blank? ? nil : labels
        }.compact
      end
    end

    Hook = Struct.new(:method_names, :package) do
    end

    OPENSSL_PACKAGES = Package.build_from_path('openssl', package_name: 'openssl', labels: %w[security crypto])

    # Methods that should always be hooked, with their containing
    # package and labels that should be applied to them.
    HOOKED_METHODS = {
      'ActiveSupport::SecurityUtils' => Hook.new(:secure_compare, Package.build_from_path('active_support', package_name: 'active_support', labels: %w[security crypto]))
    }.freeze

    BUILTIN_METHODS = {
      'OpenSSL::PKey::PKey' => Hook.new(:sign, OPENSSL_PACKAGES),
      'Digest::Instance' => Hook.new(:digest, OPENSSL_PACKAGES),
      'OpenSSL::X509::Request' => Hook.new(%i[sign verify], OPENSSL_PACKAGES),
      'OpenSSL::PKCS5' => Hook.new(%i[pbkdf2_hmac_sha1 pbkdf2_hmac], OPENSSL_PACKAGES),
      'OpenSSL::Cipher' => Hook.new(%i[encrypt decrypt final], OPENSSL_PACKAGES),
      'OpenSSL::X509::Certificate' => Hook.new(:sign, OPENSSL_PACKAGES),
      'Net::HTTP' => Hook.new(:request, Package.build_from_path('net/http', package_name: 'net/http', labels: %w[http io])),
      'Net::SMTP' => Hook.new(:send, Package.build_from_path('net/smtp', package_name: 'net/smtp', labels: %w[smtp email io])),
      'Net::POP3' => Hook.new(:mails, Package.build_from_path('net/pop3', package_name: 'net/pop', labels: %w[pop pop3 email io])),
      'Net::IMAP' => Hook.new(:send_command, Package.build_from_path('net/imap', package_name: 'net/imap', labels: %w[imap email io])),
      'Marshal' => Hook.new(%i[dump load], Package.build_from_path('marshal', labels: %w[serialization marshal])),
      'Psych' => Hook.new(%i[dump dump_stream load load_stream parse parse_stream], Package.build_from_path('yaml', package_name: 'psych', labels: %w[serialization yaml])),
      'JSON::Ext::Parser' => Hook.new(:parse, Package.build_from_path('json', package_name: 'json', labels: %w[serialization json])),
      'JSON::Ext::Generator::State' => Hook.new(:generate, Package.build_from_path('json', package_name: 'json', labels: %w[serialization json]))
    }.freeze

    attr_reader :name, :packages

    def initialize(name, packages = [])
      @name = name
      @packages = packages
    end

    class << self
      # Loads configuration data from a file, specified by the file name.
      def load_from_file(config_file_name)
        require 'yaml'
        load YAML.safe_load(::File.read(config_file_name))
      end

      # Loads configuration from a Hash.
      def load(config_data)
        packages = (config_data['packages'] || []).map do |package|
          gem = package['gem']
          path = package['path']
          raise 'AppMap package configuration should specify gem or path, not both' if gem && path

          if gem
            Package.build_from_gem(gem, exclude: package['exclude'] || [])
          else
            [ Package.build_from_path(path, exclude: package['exclude'] || []) ]
          end
        end.flatten
        Config.new config_data['name'], packages
      end
    end

    def to_h
      {
        name: name,
        packages: packages.map(&:to_h)
      }
    end

    def package_for_method(method)
      defined_class, _, method_name = ::AppMap::Hook.qualify_method_name(method)
      package = find_package(defined_class, method_name)
      return package if package

      location = method.source_location
      location_file, = location
      return unless location_file

      location_file = location_file[Dir.pwd.length + 1..-1] if location_file.index(Dir.pwd) == 0
      packages.find do |pkg|
        (location_file.index(pkg.path) == 0) &&
          !pkg.exclude.find { |p| location_file.index(p) }
      end
    end

    def included_by_location?(method)
      !!package_for_method(method)
    end

    def always_hook?(defined_class, method_name)
      !!find_package(defined_class, method_name)
    end

    def find_package(defined_class, method_name)
      hook = find_hook(defined_class)
      return nil unless hook

      Array(hook.method_names).include?(method_name) ? hook.package : nil
    end

    def find_hook(defined_class)
      HOOKED_METHODS[defined_class] || BUILTIN_METHODS[defined_class]
    end
  end
end
