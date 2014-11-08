require './rubygoal/field'
require './rubygoal/moveable'
require './rubygoal/util'

module Rubygoal
  class Ball
    IMAGE_SIZE = 20

    include Moveable

    def initialize(window, position)
      super()

      @position = position
    end

    def goal?
      Field.goal?(position)
    end

    def move(direction, speed)
      self.velocity = Velocity.new(
        Util.offset_x(direction, speed),
        Util.offset_y(direction, speed)
      )
    end

    def draw
      half_side_lenght = IMAGE_SIZE / 2
      image_center_x = position.x - half_side_lenght
      image_center_y = position.y - half_side_lenght

      image.draw(image_center_x, image_center_y, 1)
    end

    def update
      super

      prevent_out_of_bounds
      decelerate
    end

    private

    def prevent_out_of_bounds
      if Field.out_of_bounds_width?(position)
        velocity.x *= -1
      end
      if Field.out_of_bounds_height?(position)
        velocity.y *= -1
      end
    end

    def decelerate
      velocity.x *= deceleration_coef
      velocity.y *= deceleration_coef
    end

    def deceleration_coef
      Rubygoal.configuration.deceleration_coef
    end

    attr_reader :image
  end
end