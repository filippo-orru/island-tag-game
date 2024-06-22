extends CharacterBody2D

const SPEED = 300.0
const GRID_SIZE = 32

var fromPos = [0, 0]
var targetPos = [0, 0]

func nextMove():
	fromPos[0] = targetPos[0]
	fromPos[1] = targetPos[1]
	
	# TODO save input "last timee direction was pressed" to make not left/right take precedence
	var xDirection = Input.get_axis("ui_left", "ui_right")
	var yDirection = Input.get_axis("ui_up", "ui_down")
	
	if xDirection:
		# TODO -1, 0 or 1. no floats on dpad
		targetPos[0] += xDirection
		get_node(".").look_at(self.position + Vector2(1 * xDirection, 0))
	elif yDirection:
		targetPos[1] += yDirection
		get_node(".").look_at(self.position + Vector2(0, 1 * yDirection))


func _process(delta):
	# Move left/right
	if fromPos[0] != targetPos[0]:
		position.x = move_toward(position.x, targetPos[0] * GRID_SIZE, delta * SPEED)
		if position.x == targetPos[0] * GRID_SIZE:
			nextMove()
	
	# Move top/down
	if fromPos[1] != targetPos[1]:
		position.y = move_toward(position.y, targetPos[1] * GRID_SIZE, delta * SPEED)
		if position.y == targetPos[1] * GRID_SIZE:
			nextMove()
			
	if fromPos == targetPos:
		nextMove()
