module Benchmark
  module Driver
    class << self
      # Main function which is used by both RubyDriver and YamlDriver.
      # @param [Benchmark::Driver::Configuration] config
      def run(config)
        validate_config(config)

        without_stdout_buffering do
          runner = Runner.find(config.runner_options.type).new(
            config.runner_options,
            output: Output.create(config),
          )
          runner.run(config)
        end
      rescue Benchmark::Driver::Error => e
        $stderr.puts "\n\nFailed to execute benchmark!\n\n#{e.class.name}:\n  #{e.message}"
        exit 1
      end

      private

      def validate_config(config)
        # TODO: make sure all scripts are the same class
      end

      # benchmark_driver ouputs logs ASAP. This enables sync flag for it.
      #
      # Currently benchmark_driver supports only output to stdout.
      # In future exetension, this may be included in Output plugins.
      def without_stdout_buffering
        sync, $stdout.sync = $stdout.sync, true
        yield
      ensure
        $stdout.sync = sync
      end
    end
  end

  # RubyDriver entrypoint.
  def self.driver(*args, &block)
    dsl = Driver::RubyDslParser.new(*args)
    block.call(dsl)

    Driver.run(dsl.configuration)
  end
end

require 'benchmark/output'
require 'benchmark/runner'
require 'benchmark/driver/error'
require 'benchmark/driver/ruby_dsl_parser'
require 'benchmark/driver/version'