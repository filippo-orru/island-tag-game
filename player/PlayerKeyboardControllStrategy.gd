class_name PlayerKeyboardControllStrategy
extends PlayerControllStrategy

var _lastInputs = {"ui_left": 0, "ui_right": 0, "ui_up": 0, "ui_down": 0}

func _input(event):
	if event.is_action_pressed("ui_left"):
		_lastInputs["ui_left"] = Time.get_ticks_msec()
		nextVector = Vector2(-1, 0)
	elif event.is_action_released("ui_left"):
		_lastInputs["ui_left"] = 0
		
	if event.is_action_pressed("ui_right"):
		_lastInputs["ui_right"] = Time.get_ticks_msec()
		nextVector = Vector2(1, 0)
	elif event.is_action_released("ui_right"):
		_lastInputs["ui_right"] = 0
		
	if event.is_action_pressed("ui_up"):
		_lastInputs["ui_up"] = Time.get_ticks_msec()
		nextVector = Vector2(0, -1)
	elif event.is_action_released("ui_up"):
		_lastInputs["ui_up"] = 0
		
	if event.is_action_pressed("ui_down"):
		_lastInputs["ui_down"] = Time.get_ticks_msec()
		nextVector = Vector2(0, 1)
	elif event.is_action_released("ui_down"):
		_lastInputs["ui_down"] = 0


func get_target_vector(position: Vector2i) -> Vector2i:
	var target = Vector2i.ZERO
	
	if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") != Vector2.ZERO:
		if nextVector != Vector2.ZERO:
			# Handle short tap
			target = nextVector
			nextVector = Vector2.ZERO
		elif _lastInputs["ui_left"] > _lastInputs["ui_right"] && _lastInputs["ui_left"] > _lastInputs["ui_up"] && _lastInputs["ui_left"] > _lastInputs["ui_down"]:
			target.x = -1
		elif _lastInputs["ui_right"] > _lastInputs["ui_up"] && _lastInputs["ui_right"] > _lastInputs["ui_down"]:
			target.x = 1
		elif _lastInputs["ui_up"] > _lastInputs["ui_down"]:
			target.y = -1
		else:
			target.y = 1
	
	return target
