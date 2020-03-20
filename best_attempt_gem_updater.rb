class BestAttemptGemUpdater

    def initialize(gems)
        @gems = gems
        @original_commit = ""
        @skipped_gems = []
        @failed_gems = []
        @updated_gems = []
    end


    def attempt_gem_update
        puts 'This is experimental software. Use at your own risk. Any damage to your code base is not my fault!'
        puts '#######'
        puts '#######'
        puts ' Are you sure you want to proceed? Type YES to continue, any other input will exit.'
        user_input = gets.chomp
        unless user_input == 'YES'
            puts 'Did not recieve YES, exiting.'
            return
        end

        unless clean_working_tree?
            puts 'A clean working tree is required. please commit your changes before you continue.'
            return
        end
        @original_commit = current_commit
        @gems.each do |gem|
            update_gem(gem)
        end
        puts 'All Done! 😸'
        puts ''
        puts '######'
        puts "#{@updated_gems.count} gems were updated. would you like to display them? Y/N"
        if gets.chomp.downcase == 'y'
            @updated_gems.each do |gem|
                puts gem
            end
            puts ''
            puts ''
        end

        puts '######'
        puts "#{@skipped_gems.count} gems did not require updates. Would you like to display them? Y/N"
        if gets.chomp.downcase == 'y'
            @skipped_gems.each do |gem|
                puts gem
            end
            puts ''
            puts ''
        end

        puts '######'
        puts "#{@failed_gems.count} gems broke rspec. Would you like to display them? Y/N"
        if gets.chomp.downcase == 'y'
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

    def update_gem(gem)
        fallback_commit = current_commit
        puts "Updating gem: #{gem}"
        if update_required?(gem)
            puts "## update required"
            if bundler_update(gem)
                if rspec_green?
                    puts "## Rspec Paased!"
                    commit_changes(gem)
                    @updated_gems << gem
                else
                    puts "## rspec failed"
                    @failed_gems << gem
                    reset_to_commit(fallback_commit)
                end
            else
                puts "## update failed"
                @failed_gems << gem
                reset_to_commit(fallback_commit)
            end
        else
            puts "## update not required"
            @skipped_gems << gem
        end
    end

    def bundler_update(gem)
        puts "## attempting update"
      system("bundle update #{gem}")
    end

    def rspec_green?
     system('rspec')
    end

    def current_commit
      `git rev-parse HEAD`.chomp
    end

    def reset_to_commit(commit)
      `git reset --hard #{commit}`
    end

    def update_required?(gem)
      `bundle outdated #{gem}`.include?('Outdated gems included in the bundle:')
    end

    def commit_changes(gem)
        `git commit -am '#{gem} was updated. Automatic commit.'`
    end

    def clean_working_tree?
        `git status`.include?('nothing to commit, working tree clean')
    end

end