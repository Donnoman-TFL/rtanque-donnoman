
require 'forwardable'
require 'ostruct'
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

module Donnoman

  module Base
    class Strategy
      extend Forwardable
      attr_reader :bot, :opts
      def_delegators :@bot,:command,:sensors
      def initialize(bot,opts={})
        @bot = bot
        @opts = opts
      end
      def change
        puts "No Change Method for #{self.class.name}"
      end
      def rotate(heading,acuteness=1,direction=1)
        target = heading.to_degrees  + ( acuteness * direction )
        target += 360 if target < 0
        target -= 360 if target > 360
        RTanque::Heading.new_from_degrees( target )
      end
      def closest
        sensors.radar.sort{|r| r.distance }
      end
      def random_direction
        [-1,1].sample
      end
      def in_degrees(radians)
        (radians * 180.0) / Math::PI
      end
    end
  end


  module Navigation
    class Spiral < Base::Strategy
      attr_writer :interval, :acuteness, :direction
      def interval
        @interval ||= 3
      end
      def acuteness
        @acuteness ||= in_degrees(RTanque::Bot::BrainHelper::MAX_BOT_ROTATION)
      end
      def direction
        @direction ||= random_direction
      end
      def change
        if sensors.position.on_wall? or sensors.ticks % interval == 0
          command.heading = rotate(sensors.heading,acuteness,direction)
        end
      end
    end
  end

  module Acceleration
    class PedalToTheMetal < Base::Strategy
      def change
        command.speed = RTanque::Bot::BrainHelper::MAX_BOT_SPEED
      end
    end
  end

  module Radar
    class Sweep < Base::Strategy
      def acuteness
        @acuteness ||= in_degrees(RTanque::Bot::BrainHelper::MAX_RADAR_ROTATION)
      end
      def direction
        @direction ||= random_direction
      end
      def change
        command.radar_heading = rotate(sensors.radar_heading,acuteness,direction)
      end
    end
    class Focused < Base::Strategy
      attr_accessor :focused
      def change
        command.radar_heading = if reflection = sensors.radar.find { |reflection| reflection.name == focused } 
          reflection.heading
        elsif closest.any?
           (focused = closest.first).heading
        end
      end
    end
    class SweepToFocused < Base::Strategy
      def focused
        @focused ||= Focused.new(bot)
      end
      def sweep
        @sweep ||= Sweep.new(bot)
      end
      def change
        if closest.any?
          focused.change
        else
          sweep.change
        end
      end
    end
  end

  module Turret
    class Closest < Base::Strategy
      def range
        opts[:range] || 5.0
      end
      def turret_fire_range
        RTanque::Heading::ONE_DEGREE * range
      end
      def insight
        closest.select{|r| r.heading.delta(sensors.turret_heading).abs < turret_fire_range }
      end
      def change
        if insight.any? and reflection = insight.first
          command.turret_heading = reflection.heading
          command.fire(RTanque::Bot::BrainHelper::MAX_FIRE_POWER) 
        else
          command.turret_heading = closest.first.heading if closest.any?
        end
      end
    end
  end


end