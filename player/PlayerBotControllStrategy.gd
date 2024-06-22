class_name PlayerBotControllStrategy
extends PlayerControllStrategy

var start_following = false
var targetPlayer: Player

func get_target_vector(position: Vector2i) -> Vector2i:
	var delta: Vector2i = (position / GameWorld.GRID_SIZE) - targetPlayer.fromPos
	
	# Give the player some head start
	if not start_following:
		if delta.length() > 10:
			start_following = true
		return Vector2i.ZERO
	
	if delta == Vector2i.ZERO:
		return delta
	elif (delta.x > delta.y and delta.x != 0) or delta.y == 0:
		if delta.x < 0:
			return Vector2i.RIGHT
		else:
			return Vector2i.LEFT
	else:
		if delta.y < 0:
			return Vector2i.DOWN
		else:
			return Vector2i.UP
