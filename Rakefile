require "rake"
require "fileutils"

# The directory for dotfiles that should be symlinked
DOTFILES_DIRECTORY = "tilde"

task default: "install"

desc "Hook our dotfiles into system-standard positions."
task :install do
  files_to_symlink(DOTFILES_DIRECTORY).each { |file| symlink_file(file) }
end

# Run as rake setup_file[file_name]
# Zsh will be kind of weird with the brackets, so do this:
#   rake 'setup_file[.my_dot_file]'
# unless you add 'unsetopt nomatch' to .zshrc, then you're good to go without the quotes
# symlink multiple files at once
# rake setup_file['.maid .vimrc .hushlogin']
desc "Symlink arbitrary files."
task :setup_file, [:file] do |t, file|
  file[:file].to_s.split.each do |single_file|
    symlink_file(single_file)
  end
end

def files_to_symlink(directory)
  files = Dir.chdir(directory) { Dir.glob("**/*", File::FNM_DOTMATCH) }
  files.select { |f| File.file? File.join(directory, f) }
end

def symlink_file(file)
  source = "#{ENV["PWD"]}/#{DOTFILES_DIRECTORY}/#{file}"
  target = "#{ENV["HOME"]}/#{file}"

  puts "Source: #{source}"
  puts "Target: #{target}"

  `mkdir -p "#{File.dirname(target)}"`

  if File.exist?(target) || File.symlink?(target)
    puts "[Overwriting] #{target}..."
  end

  `ln -nfvs "#{source}" "#{target}"`
end
