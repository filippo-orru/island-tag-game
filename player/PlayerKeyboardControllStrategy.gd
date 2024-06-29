class_name PlayerKeyboardControllStrategy
extends PlayerControllStrategy

@export var useItem: Callable

const MOVE_LEFT = "MoveLeft"
const MOVE_UP = "MoveUp"
const MOVE_RIGHT = "MoveRight"
const MOVE_DOWN = "MoveDown"

var _lastInputs = {MOVE_LEFT: 0, MOVE_UP: 0, MOVE_RIGHT: 0, MOVE_DOWN: 0}

func _input(event: InputEvent):
	# Movement ---
	if event.is_action_pressed(MOVE_LEFT):
		_lastInputs[MOVE_LEFT] = Time.get_ticks_msec()
		nextVector = Vector2(-1, 0)
	elif event.is_action_released(MOVE_LEFT):
		_lastInputs[MOVE_LEFT] = 0
		
	if event.is_action_pressed(MOVE_RIGHT):
		_lastInputs[MOVE_RIGHT] = Time.get_ticks_msec()
		nextVector = Vector2(1, 0)
	elif event.is_action_released(MOVE_RIGHT):
		_lastInputs[MOVE_RIGHT] = 0
		
	if event.is_action_pressed(MOVE_UP):
		_lastInputs[MOVE_UP] = Time.get_ticks_msec()
		nextVector = Vector2(0, -1)
	elif event.is_action_released(MOVE_UP):
		_lastInputs[MOVE_UP] = 0
		
	if event.is_action_pressed(MOVE_DOWN):
		_lastInputs[MOVE_DOWN] = Time.get_ticks_msec()
		nextVector = Vector2(0, 1)
	elif event.is_action_released(MOVE_DOWN):
		_lastInputs[MOVE_DOWN] = 0
	
	# Items ---
	if event.is_action_pressed("UseItem"):
		useItem.call()


func get_target_vector(position: Vector2i) -> Vector2i:
	var target = Vector2i.ZERO
	
	if Input.get_vector(MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN) != Vector2.ZERO:
		if nextVector != Vector2.ZERO:
			# Handle short tap
			target = nextVector
			nextVector = Vector2.ZERO
		elif _lastInputs[MOVE_LEFT] > _lastInputs[MOVE_RIGHT] && _lastInputs[MOVE_LEFT] > _lastInputs[MOVE_UP] && _lastInputs[MOVE_LEFT] > _lastInputs[MOVE_DOWN]:
			target.x = -1
		elif _lastInputs[MOVE_RIGHT] > _lastInputs[MOVE_UP] && _lastInputs[MOVE_RIGHT] > _lastInputs[MOVE_DOWN]:
			target.x = 1
		elif _lastInputs[MOVE_UP] > _lastInputs[MOVE_DOWN]:
			target.y = -1
		else:
			target.y = 1
	
	return target
