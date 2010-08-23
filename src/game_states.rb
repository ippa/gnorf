class MenuState < GameState
  def initialize
    super 
    
    SimpleMenu.create(
      :menu_items => {"Start Game" => :start_game, "Online HighScores" => :high_scores, "Rewatch Intro" => :intro, "Quit" => :exit}, 
      :size => 20,
      :factor => 3,
      :padding => 10
    )
    
    $window.reset_game
  end

  def start_game
    $window.next_level
  end
  
  def high_scores
    switch_game_state(HighScoreState)
  end
  
  def intro
    switch_game_state(Intro)
  end
  
end


class Intro < GameState
  trait :timer
  
  def setup
    on_input([:space, :esc, :enter, :backspace, :gamepad_button_1, :return]) { switch_game_state(MenuState) }
    GameObject.create(:image => Image["intro.png"], :x => 0, :y => 0, :rotation_center => :top_left)
    @fader = GameObject.create(:image => Image["intro_fader.png"], :x => 50, :y => 0, :rotation_center => :top_left)
    between(5000,15000) { @fader.x -= 1 }.then { switch_game_state(MenuState) }
  end
  
  def draw
    fill(Color::BLACK)
    super
  end

end


class HighScoreState < GameState 
  def setup
    on_input([:esc, :space, :backspace, :gamepad_button_1]) { switch_game_state(MenuState) }
    Text.create("HIGH SCORES", :x => 200, :y => 10, :size => 40, :align => :center)
    create_text
  end
  
  def create_text
    Text.destroy_if { |text| text.size == 20 }
    
    #
    # Iterate through all high scores and create the visual represenation of it
    #
    $window.high_score_list.each_with_index do |high_score, index|
      y = index * 30 + 100
      Text.create(high_score[:name], :x => 200, :y => y, :size => 17)
      Text.create(high_score[:score], :x => 400, :y => y, :size => 17)
      Text.create(high_score[:text], :x => 600, :y => y, :size => 17)
    end
  end
end


class EnterNameState < GameState
  trait :timer
  
  def initialize
    super
    
    if position = $window.high_score_list.position_by_score($window.score) < 20
      #Text.create("You made position nr. #{position.to_s}! Please enter your name!", :x => 10, :y => 10, :size => 30, :align => :center)
      Text.create("High Score! Please enter your name.", :x => 10, :y => 10, :size => 25, :align => :center)
    else
      switch_game_state(MenuState)
    end
    
    self.input = {  [:holding_left, :holding_a, :holding_gamepad_left] => :left, 
                    [:holding_right, :holding_d, :holding_gamepad_right] => :right,
                    [:space, :x, :enter, :gamepad_button_1, :return] => :action
                 }
    
    @string = []
    @texts = []
    @start_y = 200
    @start_x = 50
    @index  = 0
    @letters = %w[ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _ < GO! ]
    x = @start_x
    
    @letters.each do |letter|
      @texts << Text.create(letter, :x => x, :y => @start_y, :rotation_center => :bottom_left)
      x += 30
    end
    
    @selected_color = Color::RED
    @cooldown = false
    @signature = Text.create("", :x => $window.width/2, :y => $window.height/2, :size => 80, :align => :center)
  end
  
  def left
    return if @cooldown
    @index -= 1
    @index = @letters.size-1  if @index < 0
    @cooldown = true; after(80) { @cooldown = false }
  end
    
  def right
    return if @cooldown
    @index += 1
    @index = 0  if @index >= @letters.size
    @cooldown = true; after(80) { @cooldown = false }
  end
  
  def action
    case @letters[@index]
      when "<"    then  @string.pop
      when "_"    then  @string << " "
      when "GO!"  then  go
      else              @string << @letters[@index]
    end
    
    @signature.text = @string.join
    @signature.x = $window.width/2 - @signature.width/2
  end
    
  def draw
    @rect = Rect.new(@start_x + (30 * @index), @start_y+30, @texts[@index].width, 10)
    fill_rect(@rect, @selected_color, 0)
    super
  end
  
  def go
    text = $window.last_level ? "Reached #{$window.last_level}" : "I got nowhere :\\"
    data = { :name => @string.join, :score => $window.score, :text => text }
    position = $window.high_score_list.add(data)
    switch_game_state(HighScoreState)
  end    
  
end
