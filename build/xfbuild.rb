#!/usr/bin/env ruby
TARGETS = {
  "spinninglights" => "../src/SpinningLights.d",
  "viewer" => "../src/Viewer.d",
}

INCLUDE_DIRS = [
  "../libs/dAssimp",
  "../libs/derelict",
  "../src"
]

#
# Parse the command line arguments.
#
require 'optparse'

compiler = "ldc"
target = TARGETS.keys.first
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

#
# Construct the xfbuild command string.
#
command = "xfbuild -w"
INCLUDE_DIRS.each { |path| command += " -I#{path}" }

build = "#{target}-#{os}-#{compiler}-#{debug ? "debug" : "release"}"
command += " +D.deps-#{build} +O.objs-#{build}"

release_opts = ""
debug_opts = ""

case compiler
when "ldc"
  # +mod-limit1 is required because LDC does not optimize well otherwise. This
  # is a bug, but has not been tracked down yet.
  command += " +cldc +q +mod-limit=1"
  command += " +C.o" if os =~ /mswin/
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
  outfile = "../bin/#{target}"
  outfile += ".exe" if os =~ /mswin/
  command += " +o#{outfile} #{TARGETS[target]}"
else
  raise "Target does not exist"
end

# Pass any additional command line options to xfBuild.
command += " " + ARGV.join(" ") unless ARGV.empty?

# Use a backslash as path separator if building on Windows.
command.gsub!(File::SEPARATOR, File::ALT_SEPARATOR) if File::ALT_SEPARATOR

#
# Invoke xfBuild.
#
puts "Building #{target}..."
puts command if verbose
raise "Build failed!" unless system command
