class Terrain < GameObject
  traits :collision_detection, :bounding_box
  
  def setup
    @image = Image["#{self.filename}.bmp"]
  end
end
class Grass < Terrain; end


class Decoration < GameObject
  traits :bounding_box
  
  def setup
    @image = Image["#{self.filename}.bmp"]
  end
end
class Flower < Decoration; end
class Skull < Decoration; end
class Bone < Decoration; end