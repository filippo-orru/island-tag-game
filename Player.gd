extends CharacterBody2D

const DEFAULT_SPEED = 200.0
const PLANK_SPAWN_SPEED = 100.0
const GRID_SIZE = 16

var fromPos = Vector2i(0, 0)
var targetPos = Vector2i(0, 0)
var currentMovementSpeed = 0.0

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
	fromPos = targetPos
	
	if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") != Vector2.ZERO:
		if lastInputs["ui_left"] > lastInputs["ui_right"] && lastInputs["ui_left"] > lastInputs["ui_up"] && lastInputs["ui_left"] > lastInputs["ui_down"]:
			$AnimationPlayer.play("walk_left")
			targetPos.x -= 1
		elif lastInputs["ui_right"] > lastInputs["ui_up"] && lastInputs["ui_right"] > lastInputs["ui_down"]:
			$AnimationPlayer.play("walk_right")
			targetPos.x += 1
		elif lastInputs["ui_up"] > lastInputs["ui_down"]:
			$AnimationPlayer.play("walk_up")
			targetPos.y -= 1
		else:
			$AnimationPlayer.play("walk_down")
			targetPos.y += 1
		
		var isTargetWalkable = World.isWalkable(targetPos)
		if !isTargetWalkable:
			World.spawn_plank(targetPos)
			currentMovementSpeed = PLANK_SPAWN_SPEED
		else:
			currentMovementSpeed = DEFAULT_SPEED

	else:
		$AnimationPlayer.stop()

func _process(delta):
	# Move left/right
	if fromPos.x != targetPos.x:
		position.x = move_toward(position.x, targetPos.x * GRID_SIZE, delta * currentMovementSpeed)
		if position.x == targetPos.x * GRID_SIZE:
			nextMove()
	
	# Move top/down
	if fromPos.y != targetPos.y:
		position.y = move_toward(position.y, targetPos.y * GRID_SIZE, delta * currentMovementSpeed)
		if position.y == targetPos.y * GRID_SIZE:
			nextMove()
			
	if fromPos == targetPos:
		nextMove()
