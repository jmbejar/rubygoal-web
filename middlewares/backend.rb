require 'faye/websocket'
require 'json'

module RubyGoal
  class Backend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app = app
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          puts "WebSocket connection open"

          # Access properties on the EM::WebSocket::Handshake object, e.g.
          # path, query_string, origin, headers
          #
          # Publish message to the client
          #ws.send "Hello Client, you connected to #{event.path}"

          @game = Rubygoal::Game.new

          @timer = EventMachine::PeriodicTimer.new(1.0 / 60) do
            @game.update
            message = {
              ball: { x: @game.field.ball.position.x - 15, y: @game.field.ball.position.y - 15},
              home: [],
              away: []
            }
            @game.field.team_home.players.values.each do |p|
              message[:home] << { x: p.position.x, y: p.position.y, angle: p.angle }
            end
            @game.field.team_away.players.values.each do |p|
              message[:away] << { x: p.position.x, y: p.position.y, angle: p.angle }
            end

            ws.send message.to_json
          end
        end

        ws.on :close do |event|
          @timer.cancel
          @game = nil
          puts "Connection closed"
        end

        ws.on :message do |event|
          puts "Recieved message: #{event.data}"
        end

        ws.rack_response
      else
        @app.call(env)
      end
    end
  end
end


#require 'faye/websocket'
#require 'json'
#require 'erb'
#require 'lib/rubygoal'

#module RubyGoal
  #class Backend
    #KEEPALIVE_TIME = 15 # in seconds

    #def initialize(app)
      #@app = app
    #end

    #def call(env)
      #if Faye::WebSocket.websocket?(env)
        #ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        #ws.on :open do |event|
          #p [:open, ws.object_id]
        #end

        #ws.on :message do |event|
          #p [:message, event.data]
        #end

        #ws.on :close do |event|
          #p [:close, ws.object_id, event.code, event.reason]
          #ws = nil
        #end

        ## Return async Rack response
        #ws.rack_response

      #else
        #@app.call(env)
      #end
    #end
  #end
#end
