require 'faye/websocket'
require 'json'

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
        away: [],
        score_home: @game.score_home,
        score_away: @game.score_away,
        time: @game.time
      }
      @game.field.team_home.players.values.each do |p|
        message[:home] << { x: p.position.x, y: p.position.y, angle: p.angle }
      end
      @game.field.team_away.players.values.each do |p|
        message[:away] << { x: p.position.x, y: p.position.y, angle: p.angle }
      end

      message
    end

    def ended?
      @game.nil?
    end

    private

    def start_game_loop
      @thread = Thread.new do
        EventMachine::PeriodicTimer.new(1.0 / 60) do
          @game.update
          finish_game if @game.ended?
        end
      end
    end

    def finish_game
      @thread.kill
      @game = nil
    end
  end

  class Backend
    def initialize(app)
      @app = app
      @game_server = GameServer.new
      @viewers = Set.new
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil)
        timer = nil
        viewer_id = nil
        last_time_sent = nil

        ws.on :open do |event|
          viewer_id = rand(100000)
          @viewers.add(viewer_id)

          puts "WebSocket connection open ##{viewer_id}"

          @game_server.start_game

          timer = EventMachine::PeriodicTimer.new(1.0 / 60) do
            if @game_server.ended?
              ws.close
            else
              message = @game_server.message
              if message[:time] != last_time_sent
                ws.send message.merge({viewers: @viewers.count}).to_json
                last_time_sent = message[:time]
              end
            end
          end
        end

        ws.on :close do |event|
          timer.cancel if timer
          @viewers.delete(viewer_id)
          puts "Connection closed ##{viewer_id}"
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
