extends Node

@export var upDownMoveSpeed = 5.0
@export var animationSpeed = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


const frameCount = 8

var elapsed = 0.0

func _process(delta):
	var timestamp = Time.get_ticks_msec()
	$Sprite2D.position.y = sin(upDownMoveSpeed * timestamp / 1000.0)
	
	elapsed += delta
	if elapsed > (animationSpeed / frameCount):
		$Sprite2D.frame = ($Sprite2D.frame + 1) % frameCount
		elapsed = 0
