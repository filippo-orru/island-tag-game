extends CharacterBody2D

const SPEED = 200.0
const GRID_SIZE = 16

var fromPos = [0, 0]
var targetPos = [0, 0]

var lastInputs = {"ui_left": 0, "ui_right": 0, "ui_up": 0, "ui_down": 0}

func _input(event):
	if event.is_action_pressed("ui_left"):
		lastInputs["ui_left"] = Time.get_ticks_msec()
	elif event.is_action_released("ui_left"):
		lastInputs["ui_left"] = 0
		
	if event.is_action_pressed("ui_right"):
		lastInputs["ui_right"] = Time.get_ticks_msec()
	elif event.is_action_released("ui_right"):
		lastInputs["ui_right"] = 0
		
	if event.is_action_pressed("ui_up"):
		lastInputs["ui_up"] = Time.get_ticks_msec()
	elif event.is_action_released("ui_up"):
		lastInputs["ui_up"] = 0
		
	if event.is_action_pressed("ui_down"):
		lastInputs["ui_down"] = Time.get_ticks_msec()
	elif event.is_action_released("ui_down"):
		lastInputs["ui_down"] = 0

func nextMove():
	fromPos[0] = targetPos[0]
	fromPos[1] = targetPos[1]
	
	if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") != Vector2.ZERO:
		if lastInputs["ui_left"] > lastInputs["ui_right"] && lastInputs["ui_left"] > lastInputs["ui_up"] && lastInputs["ui_left"] > lastInputs["ui_down"]:
			targetPos[0] -= 1
			get_node(".").look_at(self.position - Vector2(1, 0))
		elif lastInputs["ui_right"] > lastInputs["ui_up"] && lastInputs["ui_right"] > lastInputs["ui_down"]:
			targetPos[0] += 1
			get_node(".").look_at(self.position + Vector2(1, 0))
		elif lastInputs["ui_up"] > lastInputs["ui_down"]:
			targetPos[1] -= 1
			get_node(".").look_at(self.position - Vector2(0, 1))
		else:
			targetPos[1] += 1
			get_node(".").look_at(self.position + Vector2(0, 1))

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
