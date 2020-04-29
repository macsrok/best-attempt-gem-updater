# best-attempt-gem-updater
A simple class to help you update gems
The Idea behind this very simple tool is to update a gem, run the test suite, and if things fail revert and then move on to the next gem in the list. If the test suite doesn't fail after an up date commit the changes and move on to the next gem in the list. I sert this up to run over night so I can work while I sleep. In the morning I get a listing of all the gems the broke my build.

Example useage:
~ irb

`gems = ['pry', 'listen', 'bullet']`
`require '/path/to/best_attempt_gem_updater.rb'`
`updater = BestAttemptGemUpdater.new(gems)`
`updater.attempt_gem_update`


Rake Task Example Usage:

`rake 'gems:attempt_update["GEMS:THAT:SHOULD:NOT:BE:UPDATED"]'`