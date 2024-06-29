extends TextureRect

@export var animationSpeed = 1.0
const frameCount = 8
var frame = 0
@onready var frameDuration = animationSpeed / frameCount

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var timestamp = Time.get_ticks_msec()
	var newFrame = int((timestamp / 1000.0) / frameDuration) % frameCount
	if newFrame != frame:
		frame = newFrame
		texture.region.position.x = frame * 16
