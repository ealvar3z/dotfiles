#!/usr/bin/env ruby

require 'fileutils'

# Define dependencies for each distro family
DEPS = {
  debian: %w[gcc libx11-dev libxt-dev libxext-dev libfontconfig1-dev],
  rpm: %w[gcc libX11-devel libXt-devel libXext-devel fontconfig-devel],
  arch: %w[gcc libx11 libxt libxext fontconfig]
}

# Function to detect the distribution
def detect_distro
  os_release = '/etc/os-release'
  return :debian if File.exist?(os_release) && File.read(os_release).include?('ID=debian')
  return :arch if File.exist?(os_release) && File.read(os_release).include?('ID=arch')
  return :rpm if File.exist?(os_release) && File.read(os_release).match?(/ID=(fedora|centos|rhel)/)

  raise 'Unsupported distribution. Only Debian, RPM, and Arch-based distros are supported.'
end

# Install dependencies based on the detected distro
def install_deps(distro)
  deps = DEPS[distro]
  case distro
  when :debian
    system("sudo apt-get update && sudo apt-get install -y #{deps.join(' ')}")
  when :rpm
    system("sudo dnf install -y #{deps.join(' ')}")
  when :arch
    system("sudo pacman -Syu --noconfirm #{deps.join(' ')}")
  end
end

# Clone the Plan 9 Port repository and install it
def install_plan9
  plan9_dir = "#{ENV['HOME']}/plan9"
  unless File.directory?(plan9_dir)
    system("git clone https://github.com/9fans/plan9port #{plan9_dir}")
  end

  Dir.chdir("#{plan9_dir}/plan9port") do
    system("./INSTALL -r #{plan9_dir}")
  end
end

# Main execution flow
begin
  puts 'Detecting Linux distribution...'
  distro = detect_distro
  puts "Detected #{distro.capitalize}-based distribution. Installing dependencies..."
  install_deps(distro)

  puts 'Installing Plan 9 Port...'
  install_plan9
  puts 'Plan 9 Port installation completed successfully!'
rescue => e
  puts "Error: #{e.message}"
end
