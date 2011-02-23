class Effect < GameObject
  trait :velocity
  attr_reader :animation

  def setup
    self.velocity = 1.0-rand*2, 1.0-rand*2
    @alpha_velocity = 4 + rand(2)
    @angle_velocity = rand(4)
    @scale_velocity = rand/10
    update
  end
  
  def update
    self.image = animation.next
    self.alpha -= @alpha_velocity
    self.angle += @angle_velocity
    self.factor += @scale_velocity
    destroy if self.alpha == 0
  end
end


class Smokepuff < Effect
  # trait :animation, :delay => 150, :loop => false  
  
  def setup
    @animation = Animation.new(:file => "smokepuff_16x16.bmp", :delay => 150, :loop => false)
    super
  end
  
end


class PuffText < Text
  traits :timer, :effect, :velocity

  def initialize(text, options = {})    
    super(text, {:y => 400, :size => 20, :center_x => 0.5}.merge(options))
    self.x = ($window.width / 2)
    self.rotation_center = :center
    puff_effect
  end
  
  def puff_effect
    self.fade_rate = -1
    self.scale_rate = 0.01
    self.velocity_y = -1
    after(4000) { destroy }
  end
end
