require 'sinatra/base'

module RubyGoal
  class App < Sinatra::Base
    get "/" do
      erb :"index.html"
    end
  end
end
