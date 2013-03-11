# @author donnoman@donovanbray.com

require File.expand_path("../../lib/donnoman",__FILE__)

class HalfSweepDizzy < RTanque::Bot::Brain
  NAME = 'turret-sweep-dizzy'
  include RTanque::Bot::BrainHelper
  attr_writer :acceleration, :navigation, :radar, :turret

  def tick!
    radar.change
    navigation.change
    acceleration.change
    turret.change
  end

  def navigation
    @navigation ||= Donnoman::Navigation::ParanoidSpiral.new(self)
  end

  def acceleration
    @acceleration ||= Donnoman::Acceleration::PedalToTheMetal.new(self)
  end

  def radar
    @radar ||= Donnoman::Radar::SweepToTurretSweep.new(self)
  end

  def turret
    @turret ||= Donnoman::Turret::Closest.new(self)
  end
end
