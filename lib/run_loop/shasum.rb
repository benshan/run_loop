require 'open3'
require 'tmpdir'
require 'fileutils'

module RunLoop
  module Shasum


    def self.shasum(path)
      return nil if !File.exist?(path)

      if File.directory?(path)
        self.shasum_for_directory(path)
      else
        self.shasum_for_file(path)
      end
    end

    private

    def self.shasum_for_file(path)
      debug_logging = RunLoop::Environment.debug?
      shasum = nil
      cmd = 'shasum'
      args = ["--portable", "#{path}"]
      if debug_logging
        puts "EXEC: #{cmd} #{args.join(' ')}"
      end
      Open3.popen3('shasum', *args) do |_, stdout, stderr, status|
        out = stdout.read.strip
        err = stderr.read.strip
        exit_status = status.value.exitstatus

        if exit_status != 0 || !err.empty?
          if debug_logging
            puts "Could not find shasum of '#{path}'; exited '#{exit_status}' with error: '#{err}'"
          end
        else
          shasum = out.split(' ').first.strip
        end
        shasum
      end
    end

    def self.shasum_for_directory(path)
      debug_logging = RunLoop::Environment.debug?
      shasum = nil
      pipe0 = ['find',  "#{path}", '-type', 'f', '-print0']
      pipe1 = ['sort', '-z']
      pipe2 = ['xargs', '-0', 'shasum', '--portable']
      pipe3 = ['shasum', '--portable']

      if debug_logging
        puts "EXEC: #{pipe0.join(' ')} | #{pipe1.join(' ')} | #{pipe2.join(' ')} | #{pipe3.join(' ')}"
      end

      err_r, err_w = IO.pipe
      out_r, out_w = IO.pipe
      Open3.pipeline_start(pipe0, pipe1, pipe2, pipe3, {:err => err_w,
                                                        :out => out_w}) do |processes|
        err_w.close
        out_w.close
        err = err_r.read.strip
        out = out_r.read.strip
        success = processes.map { |process| process.value.exitstatus == 0 }.all?

        if !success || !err.empty?
          if debug_logging
            statuses = processes.map { |process| process.value.exitstatus }
            puts "Could not find shasum of '#{path}'; exited '#{statuses}' with error: '#{err}'"
          end
        else
          shasum = out.split(' ').first.strip
        end
        shasum
      end
    end
  end
end
