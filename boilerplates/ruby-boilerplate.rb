#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby command-line script template. Run with --help; requiring this file has no
# application side effects. The example is a line filter for files or stdin.
# Inspired by:
# https://practicingruby.com/articles/building-unix-style-command-line-applications
# https://www.devdungeon.com/content/enhanced-shell-scripting-ruby

require "io/console"
require "open3"
require "optparse"

module RubyBoilerplate
  module Helpers
    module_function

    # Prompts belong on stderr. Return nil on EOF rather than calling chomp on nil.
    def prompt(message, input: $stdin, output: $stderr)
      output.print("#{message} ")
      output.flush
      input.gets&.chomp
    end

    # Read a password without echoing it; never log the result.
    def password(message = "Password: ", console: IO.console)
      raise IOError, "an interactive console is required" unless console

      console.getpass(message)
    end

    # Return [stdout, stderr, Process::Status]. The executable/argv0 pair forces
    # direct execution, even for a single argument containing shell metacharacters.
    def capture_command(program, *arguments, **options)
      Open3.capture3([program, program], *arguments, **options)
    end
  end

  class Renderer
    def initialize(options, output)
      @options = options
      @output = output
      @line_number = 0
      @previous_blank = false
    end

    def render(input)
      input.each_line do |line|
        blank = line.chomp.empty?
        next if @options[:squeeze_blank] && blank && @previous_blank

        @previous_blank = blank
        number = @options[:number_nonblank] ? !blank : @options[:number]
        if number
          @line_number += 1
          @output.printf("%6d\t", @line_number)
        end
        @output.write(line)
      end
    end
  end

  class Application
    def initialize(argv, input:, output:, program:)
      @input = input
      @output = output
      @help_requested = false
      @options = { number: false, number_nonblank: false, squeeze_blank: false }
      @parser = OptionParser.new do |parser|
        parser.banner = "Usage: #{program} [OPTIONS] [FILE ...]"
        parser.separator("Read stdin when no files are supplied, or use '-' as a filename.")
        parser.on("-n", "--number", "Number every output line") { @options[:number] = true }
        parser.on("-b", "--number-nonblank", "Number nonblank lines; overrides -n") { @options[:number_nonblank] = true }
        parser.on("-s", "--squeeze-blank", "Collapse consecutive blank lines") { @options[:squeeze_blank] = true }
        parser.on("-h", "--help", "Show this help and exit") { @help_requested = true }
      end
      # Do not mutate the caller's ARGV or array when used as a library.
      @files = @parser.parse(argv.dup)
    end

    def run
      if @help_requested
        @output.puts(@parser)
        @output.flush
        return 0
      end

      renderer = Renderer.new(@options, @output)
      files = @files.empty? ? ["-"] : @files
      files.each do |filename|
        if filename == "-"
          renderer.render(@input)
        else
          File.open(filename, "r") { |file| renderer.render(file) }
        end
      end
      @output.flush
      0
    end
  end

  # Keep expected failures concise; unexpected programming errors retain a stack
  # trace. Returning a code here also makes the application easy to test in-process.
  def self.main(argv = ARGV, input: $stdin, output: $stdout, error: $stderr,
                program: File.basename($PROGRAM_NAME))
    Application.new(argv, input: input, output: output, program: program).run
  rescue OptionParser::ParseError => e
    error.puts("#{program}: #{e.message}\nTry '#{program} --help' for usage.")
    2
  rescue Errno::EPIPE
    0 # A downstream consumer such as head closed the pipe.
  rescue SystemCallError, IOError => e
    error.puts("#{program}: #{e.message}")
    1
  rescue Interrupt
    error.puts("#{program}: interrupted")
    130
  end
end

# Recipes to adapt when replacing the sample filter:
#
# shell = ENV.fetch("SHELL", "/bin/sh")       # Read environment with a default.
# ENV["SOME_VAR"] = "value"                  # Affects this process and children.
# File.open("output.txt", "w") { |file| file.puts("result") }
# output, errors, result = RubyBoilerplate::Helpers.capture_command("git", "status", "--short")
# result.success?; result.exitstatus; result.pid
#
# For work that does not need captured output, spawn with argument arrays and
# always reap the specific child. Avoid global waits or busy loops:
# pid = Process.spawn(["sleep", "sleep"], "1")
# _pid, result = Process.wait2(pid)
#
# Handle an expected negative answer explicitly:
# answer = RubyBoilerplate::Helpers.prompt("Continue? [y/N]")
# proceed = answer&.casecmp?("y") || answer&.casecmp?("yes")

exit(RubyBoilerplate.main) if $PROGRAM_NAME == __FILE__
