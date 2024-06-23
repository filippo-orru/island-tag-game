class_name Player
extends CharacterBody2D

const DEFAULT_SPEED = 200.0
const PLANK_SPAWN_SPEED = 100.0
const GRID_SIZE = GameWorld.GRID_SIZE

@export var fromPos = Vector2i(0, 0)
@export var targetPos = Vector2i(0, 0)
@export var currentMovementSpeed = 0.0

@export var playerName: String

# Set by the authority, synchronized on spawn.
@export var playerId := 1 :
	set(id):
		playerId = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInputSync.set_multiplayer_authority(id)


var controller: PlayerControllStrategy

func _ready():
	var playerTag = $Control/MarginContainer/MarginContainer2/CenterContainer/PlayerTag
	playerTag.text = playerName
	fromPos = Vector2i(position / GRID_SIZE)
	targetPos = Vector2i(position / GRID_SIZE)

func _input(event):
	controller._input(event)

func nextMove():
	fromPos = targetPos

	var changeVector = controller.get_target_vector(position)
	if not test_move(Transform2D(0, position), changeVector * GRID_SIZE):
		targetPos = fromPos + changeVector
	
	if not GameWorld.isWalkable(targetPos):
		GameWorld.spawn_plank(fromPos, targetPos)
		currentMovementSpeed = PLANK_SPAWN_SPEED
	else:
		currentMovementSpeed = DEFAULT_SPEED

func _process(delta):
	# Animation
	
	var changeVector = targetPos - fromPos
	
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
	
	# Movement
	
	if fromPos.x != targetPos.x:
		# Move left/right
		position.x = move_toward(position.x, targetPos.x * GRID_SIZE, delta * currentMovementSpeed)
		
		if position.x == targetPos.x * GRID_SIZE:
			nextMove()
			
	elif fromPos.y != targetPos.y:
		# Move top/down
		position.y = move_toward(position.y, targetPos.y * GRID_SIZE, delta * currentMovementSpeed)
		if position.y == targetPos.y * GRID_SIZE:
			nextMove()
	elif fromPos == targetPos:
		nextMove()
