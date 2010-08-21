#!/usr/bin/env ruby
require 'rubygems' rescue nil
require "../chingu/lib/chingu"
#require 'chingu'
include Gosu
include Chingu

require_rel 'src/*'
DEBUG = false
ENV['PATH'] = File.join(ROOT, "lib") + ";" + ENV['PATH'] # so ocra finds fmod.dll

class Game < Chingu::Window 
  
  def initialize
    super(1000,640)
  end
  
  def setup
    retrofy
    self.factor = 2
    push_game_state(Level1)
  end    
end

Game.new.show