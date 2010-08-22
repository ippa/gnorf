#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
#require 'rest_client'
#require 'crack/xml'

begin
  raise LoadError if defined?(Ocra)
  require '../chingu/lib/chingu'
rescue LoadError
  require 'chingu'
end

ENV['PATH'] = File.join(ROOT,"lib") + ";" + ENV['PATH']

include Gosu
include Chingu

DEBUG = false
require_all File.join(ROOT, "src")
exit if defined?(Ocra)


class Game < Chingu::Window
  attr_accessor :levels, :score, :lives
  
  def initialize
    super(1000,640)
  end
  
  def setup
    retrofy
    self.factor = 2
    reset_game
    
    gamercv = YAML.load_file(File.join(ROOT, "gamercv.yml"))
    #@high_score_list = OnlineHighScoreList.new(:game_id => 14, :login => gamercv["login"], :password => gamercv["password"], :limit => 10)
    #data = {:name => "TEST", :score => 0, :text => "just a test." }
    #position = @high_score_list.add(data)
    #puts "got position: #{position}"
    
    push_game_state(Level1)
    #push_game_state(Intro)    
  end
  
  def reset_game
    @levels = [Level1, Level2, Level3, Level4, Level5, Level6, Level7, Level8, Level9, Level10]
    @score = 0
    @lives = 3
  end
  
  def next_level
    switch_game_state($window.levels.shift)
  end
  
end

Game.new.show