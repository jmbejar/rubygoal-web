require 'faye/websocket'
require 'json'
require 'byebug'

module RubyGoal
  class GameServer
    def start_game
      return if @game

      @game = Rubygoal::Game.new
      start_game_loop
    end

    def message
      return "" unless @game

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

      message
    end

    private

    def start_game_loop
      @timer = EventMachine::PeriodicTimer.new(1.0 / 60) do
        @game.update
        finish_game if @game.ended?
      end
    end

    def finish_game
      @timer.cancel
      @game = nil
    end
  end

  class Backend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app = app
      @game_server = GameServer.new
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        timer = nil

        ws.on :open do |event|
          puts "WebSocket connection open"

          @game_server.start_game

          timer = EventMachine::PeriodicTimer.new(1.0 / 60) do
            ws.send @game_server.message.to_json
          end
        end

        ws.on :close do |event|
          timer.cancel if timer
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
