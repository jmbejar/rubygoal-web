require './app'
require './middlewares/backend'
require './rubygoal'

use RubyGoal::Backend

run RubyGoal::App
