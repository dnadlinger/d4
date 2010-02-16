#!/usr/bin/env ruby
TARGETS = {
  "spinninglights" => "../src/SpinningLights.d",
  "viewer" => "../src/Viewer.d",
}

#
# Parse the command line arguments.
#
require 'optparse'

compiler = "ldc"
target = "spinninglights"
debug = false
verbose = false

OptionParser.new do |opts|
  opts.banner = "Usage: xfbuild.rb [options]"

  opts.on("--compiler COMPILER", "The compiler to use.") do |v|
    compiler = v
  end

  opts.on("--target TARGET", "The target to build.") do |v|
    target = v
  end

  opts.on("--debug", "Build in debug mode.") do
    debug = true
  end

  opts.on("--verbose", "Show the xfBuild command that is executed.") do
    verbose = true
  end

  opts.on("--help", "Display this screen") do
    puts opts
    exit
  end
end.parse!

#
# Determine the operating system.
#
require 'rbconfig'
os = Config::CONFIG['target_os']
raise "Operating system not supported" unless os == "linux"

#
# Construct the xfbuild command string.
#
command = "xfbuild -I../libs/dAssimp -I../libs/derelict -I../src -w"
build = "#{target}-#{os}-#{compiler}-#{debug ? "debug" : "release"}"
command += " +D.deps-#{build} +O.objs-#{build}"

release_opts = ""
debug_opts = ""

case compiler
when "ldc"
  # +modLimit1 is required because LDC does not optimize well otherwise. This
  # is a bug, but has not been tracked down yet.
  command += " +cldc +q +modLimit1"
  release_opts = " -O5 -release"
  debug_opts = " -gc -d-debug"
when "dmd"
  command += " +cdmd"
  release_opts = " -O -release"
  debug_opts = " -gc -debug"
else
  raise "Compiler not supported."
end

if debug
  command += debug_opts
else
  command += release_opts
end

if TARGETS.include? target
  command += " +o../bin/#{target} #{TARGETS[target]}"
else
  raise "Target does not exist"
end

command += " " + ARGV.join(" ") unless ARGV.empty?

#
# Invoke xfBuild.
#
puts command if verbose
system command
