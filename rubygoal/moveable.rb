require './rubygoal/coordinate'
require './rubygoal/util'

module Rubygoal
  module Moveable
    MIN_DISTANCE = 10

    attr_accessor :position, :velocity, :angle

    def initialize
      @position = Position.new(0, 0)
      @velocity = Velocity.new(0, 0)
      @speed = 0
      @destination = nil
    end

    def moving?
      velocity.nonzero?
    end

    def distance(position)
      Util.distance(self.position.x, self.position.y, position.x, position.y)
    end

    def move_to(destination)
      self.destination = destination

      self.angle = Util.angle(position.x, position.y, destination.x, destination.y)
      velocity.x = Util.offset_x(angle, speed)
      velocity.y = Util.offset_y(angle, speed)
    end

    def update(elapsed_time)
      return unless moving?

      if destination && distance(destination) < MIN_DISTANCE
        stop
      else
        time_factor = elapsed_time / (1.0 / 60.0)

        position.x += velocity.x * time_factor
        position.y += velocity.y * time_factor
      end
    end

    private

    attr_reader :speed
    attr_accessor :destination

    def stop
      self.destination = nil
      self.velocity = Velocity.new(0, 0)
      self.angle = 0
    end
  end
end
