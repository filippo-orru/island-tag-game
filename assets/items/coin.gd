extends Node

@export var upDownMoveSpeed = 5.0
@export var animationSpeed = 1.0
@export var respawnTimeMs = 5000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

@onready var sprite = %Sprite2D
const frameCount = 8
var elapsed = 0.0

var collectedAtTimestamp = -respawnTimeMs

func _process(delta):
	var timestamp = Time.get_ticks_msec()
	sprite.position.y = sin(upDownMoveSpeed * timestamp / 1000.0)
	
	elapsed += delta
	if elapsed > (animationSpeed / frameCount):
		sprite.frame = (sprite.frame + 1) % frameCount
		elapsed = 0
	
	self.visible = _is_visible(timestamp)

func _is_visible(timestamp):
	return timestamp - collectedAtTimestamp > respawnTimeMs

func _on_area_2d_body_entered(body):
	var timestamp = Time.get_ticks_msec()
	if body is Player and _is_visible(timestamp):
		collectedAtTimestamp = Time.get_ticks_msec()
		body.collect_coin(self)
