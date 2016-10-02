require 'rake'
require 'yaml'
require 'rspec/core/rake_task'

namespace :serverspec do
  desc "Run serverspec"
  RSpec::Core::RakeTask.new('run') do |t|
    OS = ENV['OS']
    RUN_LIST = ENV['RUN_LIST'] || 'base,dev,dotfiles,messaging,multimedia'
    t.pattern = "spec/{common,#{OS}}/{#{RUN_LIST}}/*_spec.rb"
  end
end
