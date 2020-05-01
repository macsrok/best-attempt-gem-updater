namespace :gems do
  desc "Attempt to update rails gems"
  task :attempt_update, [:ignored_gems]  => :environment do |t, args|
    blacklisted = args.with_defaults(ignored_gems: "")[:ignored_gems].split(':')
    @gems = gems_to_update_bagu(blacklisted)
    @original_commit = ""
    @skipped_gems = []
    @failed_gems = []
    @updated_gems = []
    attempt_gem_update_bagu
  end
end

def fetch_gems_bagu
  Bundler::Definition.build('Gemfile', nil, {}).dependencies.map { |g| g.name }
end

def gems_to_update_bagu(ignored_gems)
  fetch_gems_bagu - ignored_gems
end

def attempt_gem_update_bagu
  puts 'This is experimental software. Use at your own risk. Any damage to your code base is not my fault!'
  puts '#######'
  puts '#######'
  puts ' Are you sure you want to proceed? Type YES to continue, any other input will exit.'
  user_input = STDIN.gets.chomp
  unless user_input == 'YES'
    puts 'Did not recieve YES, exiting.'
    return
  end

  unless clean_working_tree_bagu?
    puts 'A clean working tree is required. please commit your changes before you continue.'
    return
  end
  @original_commit = current_commit_bagu
  @gems.each do |gem|
    update_gem_bagu(gem)
  end
  puts 'All Done! 😸'
  puts ''
  puts '######'
  puts "#{@updated_gems.count} gems were updated. would you like to display them? Y/N"
  if STDIN.gets.chomp.downcase == 'y'
    @updated_gems.each do |gem|
      puts gem
    end
    puts ''
    puts ''
  end

  puts '######'
  puts "#{@skipped_gems.count} gems did not require updates. Would you like to display them? Y/N"
  if STDIN.gets.chomp.downcase == 'y'
    @skipped_gems.each do |gem|
      puts gem
    end
    puts ''
    puts ''
  end

  puts '######'
  puts "#{@failed_gems.count} gems broke rspec. Would you like to display them? Y/N"
  if STDIN.gets.chomp.downcase == 'y'
    @failed_gems.each do |gem|
      puts gem
    end
    puts ''
    puts ''
  end

  puts ''
  puts ''
  puts '######'
  puts 'If this broke your app Please run the following command to get back to where we started.'
  puts "git reset --hard #{@original_commit}"

end

def update_gem_bagu(gem)
  fallback_commit = current_commit_bagu
  puts "Updating gem: #{gem}"
  if update_required_bagu?(gem)
    puts "## update required"
    if bundler_update_bagu(gem)
      if rspec_green_bagu?
        puts "## Rspec Paased!"
        commit_changes_bagu(gem)
        @updated_gems << gem
      else
        puts "## rspec failed"
        @failed_gems << gem
        reset_to_commit_bagu(fallback_commit)
      end
    else
      puts "## update failed"
      @failed_gems << gem
      reset_to_commit_bagu(fallback_commit)
    end
  else
    puts "## update not required"
    @skipped_gems << gem
  end
end

def bundler_update_bagu(gem)
  puts "## attempting update"
  system("bundle update #{gem}")
end

def rspec_green_bagu?
  system('rspec --fail-fast')
end

def current_commit_bagu
  `git rev-parse HEAD`.chomp
end

def reset_to_commit_bagu(commit)
  `git reset --hard #{commit}`
end

def update_required_bagu?(gem)
  `bundle outdated #{gem}`.include?('Outdated gems included in the bundle:')
end

def commit_changes_bagu(gem)
  `git commit -am '#{gem} was updated. Automatic commit.'`
end

def clean_working_tree_bagu?
  `git status`.include?('nothing to commit, working tree clean')
end
