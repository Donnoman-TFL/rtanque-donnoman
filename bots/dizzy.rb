require 'debugger'

  # RTanque::Bot::BrainHelper::BOT_RADIUS          = Bot::RADIUS
  # RTanque::Bot::BrainHelper::MAX_FIRE_POWER      = Bot::MAX_FIRE_POWER
  # RTanque::Bot::BrainHelper::MIN_FIRE_POWER      = Bot::MIN_FIRE_POWER
  # RTanque::Bot::BrainHelper::MAX_HEALTH          = Bot::MAX_HEALTH
  # RTanque::Bot::BrainHelper::MAX_BOT_SPEED       = Bot::MAX_SPEED
  # RTanque::Bot::BrainHelper::MAX_BOT_ROTATION    = Configuration.bot.turn_step
  # RTanque::Bot::BrainHelper::MAX_TURRET_ROTATION = Configuration.turret.turn_step
  # RTanque::Bot::BrainHelper::MAX_RADAR_ROTATION  = Configuration.radar.turn_step


  # RTanque::Heading::FULL_ANGLE   =      Math::PI * 2.0
  # RTanque::Heading::HALF_ANGLE   =      Math::PI
  # RTanque::Heading::EIGHTH_ANGLE =      Math::PI / 4.0
  # RTanque::Heading::ONE_DEGREE   =      FULL_ANGLE / 360.0
  # RTanque::Heading::FULL_RANGE   =      (0..FULL_ANGLE)

  # RTanque::Heading::NORTH = N =         0.0
  # RTanque::Heading::NORTH_EAST = NE =   1.0 * EIGHTH_ANGLE
  # RTanque::Heading::EAST = E =          2.0 * EIGHTH_ANGLE
  # RTanque::Heading::SOUTH_EAST = SE =   3.0 * EIGHTH_ANGLE
  # RTanque::Heading::SOUTH = S =         4.0 * EIGHTH_ANGLE
  # RTanque::Heading::SOUTH_WEST = SW =   5.0 * EIGHTH_ANGLE
  # RTanque::Heading::WEST = W =          6.0 * EIGHTH_ANGLE
  # RTanque::Heading::NORTH_WEST = NW =   7.0 * EIGHTH_ANGLE

class Dizzy < RTanque::Bot::Brain
  include RTanque::Bot::BrainHelper
  NAME = 'dizzy'

  def tick!
    navigation.change
    speed.change
  end

  private

  def speed
    @speed ||= Drive::Speed.new(self)
  end

  def navigation
    @navigation ||= Drive::Navigation::Spiral.new(self)
  end

end


module Drive

  module Navigation
    class Spiral
      attr_accessor :bot, :interval, :acuteness, :direction, :escape
      def initialize(actor)
        self.bot = actor
        self.interval = 2
        self.acuteness = 1
        self.direction = [-1,1].sample
      end
      def change
        if bot.sensors.position.on_wall? or bot.sensors.ticks % interval == 0
          target = bot.sensors.heading.to_degrees  + ( direction * acuteness )
          target += 360 if target < 0
          target -= 360 if target > 360
          bot.command.heading = RTanque::Heading.new_from_degrees( target ) 
        end
      end
    end
  end

  class Speed
    attr_accessor :bot
    def initialize(actor)
      self.bot = actor
    end
    def change
      bot.command.speed = RTanque::Bot::BrainHelper::MAX_BOT_SPEED
    end
  end

end

