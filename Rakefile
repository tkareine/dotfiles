require "fileutils"

EXCLUDES = %w{Rakefile README.md}.freeze
AS_IS = Dir['bin/**/*'].freeze

def in_home(file)
  file = AS_IS.include?(file) ? file : ".#{file}"
  File.join(ENV['HOME'], file)
end

desc "Install dot files that you don't have into your home directory"
task :install do
  Dir['**/*'].each do |file|
    next if File.directory? file
    next if EXCLUDES.include? file

    destination = in_home(file)

    if !File.exist? destination
      source = File.expand_path(file)
      puts "linking: #{destination} -> #{source}"
      FileUtils.ln_s(source, destination)
    elsif File.symlink?(destination) && File.identical?(File.readlink(destination), file)
      puts "installed already, skipping: #{destination}"
    else
      puts "exists already, skipping: #{destination}"
    end
  end
end
