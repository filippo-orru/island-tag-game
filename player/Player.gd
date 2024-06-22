class_name Player
extends CharacterBody2D

const DEFAULT_SPEED = 200.0
const PLANK_SPAWN_SPEED = 100.0
const GRID_SIZE = GameWorld.GRID_SIZE

var fromPos = Vector2i(0, 0)
var targetPos = Vector2i(0, 0)
var currentMovementSpeed = 0.0

var playerName: String
var controller: PlayerControllStrategy

func _ready():
	var playerTag = $Control/MarginContainer/MarginContainer2/CenterContainer/PlayerTag
	playerTag.text = playerName

func _input(event):
	controller._input(event)

func nextMove():
	fromPos = targetPos
	
	var changeVector = controller.get_target_vector()
	if not test_move(Transform2D(0, position), changeVector * GRID_SIZE):
		targetPos = fromPos + changeVector
	else:
		changeVector = Vector2i.ZERO
	
	if changeVector.x < 0:
		$AnimationPlayer.play("walk_left")
	elif changeVector.x > 0:
		$AnimationPlayer.play("walk_right")
	elif changeVector.y < 0:
		$AnimationPlayer.play("walk_up")
	elif changeVector.y > 0:
		$AnimationPlayer.play("walk_down")
	else:
		$AnimationPlayer.stop()
	
	if not GameWorld.isWalkable(targetPos):
		GameWorld.spawn_plank(fromPos, targetPos)
		currentMovementSpeed = PLANK_SPAWN_SPEED
	else:
		currentMovementSpeed = DEFAULT_SPEED

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
