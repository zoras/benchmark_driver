module BenchmarkDriver
  module Asdf
    # @param [String] version
    def self.ruby_path(version)
      path = `ASDF_RUBY_VERSION='#{version}' asdf which ruby`.rstrip
      unless $?.success?
        abort "Failed to execute 'asdf which ruby'"
      end
      path
    end

    # @param [String] full_spec - "2.5.0", "2.5.0,--jit", "JIT::2.5.0,--jit", etc.
    def self.parse_spec(full_spec)
      name, spec = full_spec.split('::', 2)
      spec ||= name # if `::` is not given, regard whole string as spec
      version, *args = spec.split(',')
      BenchmarkDriver::Config::Executable.new(
        name: name,
        command: [BenchmarkDriver::Asdf.ruby_path(version), *args],
      )
    end
  end
end
