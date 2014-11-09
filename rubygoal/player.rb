require './rubygoal/coordinate'
require './rubygoal/moveable'
require './rubygoal/configuration'
require './rubygoal/util'

module Rubygoal
  class Player
    STRAIGHT_ANGLE = 180

    include Moveable

    def initialize(game_window, side)
      super()

      @time_to_kick_again = 0
      @field = game_window.field
      @angle = 0
    end

    def can_kick?(ball)
      !waiting_to_kick_again? && control_ball?(ball)
    end

    def kick(ball, target)
      direction = random_direction(target)
      strength = random_strength

      ball.move(direction, strength)
      reset_waiting_to_kick!
    end

    def update(elapsed_time)
      update_waiting_to_kick!(elapsed_time)
      super
    end

    def draw
      if moving?
        @angle = Util.angle(position.x, position.y, destination.x, destination.y)
        @angle -= 90
      else
        @angle = 0.0
      end

      image.draw_rot(position.x, position.y, 1, angle)
    end

    protected

    attr_accessor :time_to_kick_again

    private

    attr_reader :field, :image, :error

    def waiting_to_kick_again?
      time_to_kick_again > 0
    end

    def reset_waiting_to_kick!
      self.time_to_kick_again = Rubygoal.configuration.kick_again_delay
    end

    def update_waiting_to_kick!(elapsed_time)
      time_factor = elapsed_time / (1.0 / 60.0)

      self.time_to_kick_again -= time_factor if waiting_to_kick_again?
    end

    def control_ball?(ball)
      distance(ball.position) < Rubygoal.configuration.distance_control_ball
    end

    def random_strength
      error_range = (1 - error)..(1 + error)
      error_coef = Random.rand(error_range)
      Rubygoal.configuration.kick_strength * error_coef
    end

    def random_direction(target)
      direction = Util.angle(position.x, position.y, target.x, target.y)

      max_angle_error = STRAIGHT_ANGLE * error
      angle_error_range = -max_angle_error..max_angle_error

      direction += Random.rand(angle_error_range)
    end
  end
end

require './rubygoal/players/average'
require './rubygoal/players/fast'
require './rubygoal/players/captain'
