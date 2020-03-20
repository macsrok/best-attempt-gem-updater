# best-attempt-gem-updater
A simple class to help you update gems


Example useage:
~ irb

`gems = ['pry', 'listen', 'bullet']`
`require '/path/to/best_attempt_gem_updater.rb'`
`updater = BestAttemptGemUpdater.new(gems)`
`updater.attempt_gem_update`
