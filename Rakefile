require 'fileutils'

DOTFILES = %w{
  .ackrc
  .autotest
  .bash_profile
  .bashrc
  .bashrc.aliases
  .bashrc.common
  .bashrc.darwin
  .bashrc.functions
  .bashrc.prompt
  .dircolors
  .gemrc
  .gitconfig
  .gitignore
  .inputrc
  .irbrc
  .sbtconfig
  .tmux.conf
  .vimrc
  .xmodmap
} + Dir['bin/**/*']

def in_home_dir(file)
  File.join ENV['HOME'], file
end

desc "Install dotfiles that you don't have into your home directory"
task :install do
  DOTFILES.each do |file|
    destination = in_home_dir file

    if !File.exist? destination
      source = File.expand_path file
      puts "linking: #{destination} -> #{source}"
      FileUtils.ln_sf source, destination
    elsif File.symlink?(destination) && File.identical?(File.readlink(destination), file)
      puts "installed already, skipping: #{destination}"
    else
      puts "exists already, skipping: #{destination}"
    end
  end
end
