class_name Player
extends CharacterBody2D

const DEFAULT_SPEED = 200.0
const PLANK_SPAWN_SPEED = 100.0
const GRID_SIZE = GameWorld.GRID_SIZE

const HUNTER_PATCH_RECT = Rect2(976, 160, 48, 48)
const RUNNER_PATCH_RECT = Rect2(0, 272, 48, 48)

@export var fromPos = Vector2i(0, 0)
@export var targetPos = Vector2i(0, 0)
@export var currentMovementSpeed = 0.0
@export var hunter := false :
	set(value):
		hunter = value
		if hunter:
			$Control/MarginContainer/NinePatchRect.region_rect = HUNTER_PATCH_RECT
		else:
			$Control/MarginContainer/NinePatchRect.region_rect = RUNNER_PATCH_RECT
		
@export var tagged = false
@export var score = 0

@export var playerName: String

# Set by the authority, synchronized on spawn.
@export var playerId := 1 :
	set(id):
		playerId = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInputSync.set_multiplayer_authority(id)


@onready var world: GameWorld = get_parent().get_parent()
@onready var playerTag = $Control/MarginContainer/MarginContainer2/CenterContainer/PlayerTag
var controller: PlayerControllStrategy

func _ready():
	fromPos = Vector2i(position / GRID_SIZE)
	targetPos = Vector2i(position / GRID_SIZE)

func _input(event):
	controller._input(event)

func nextMove():
	fromPos = targetPos
	if tagged:
		return

	var changeVector = controller.get_target_vector(position)
	if not test_move(Transform2D(0, position), changeVector * GRID_SIZE):
		targetPos = fromPos + changeVector
	
	if not world.isWalkable(targetPos):
		world.spawn_plank.rpc(fromPos, targetPos)
		currentMovementSpeed = PLANK_SPAWN_SPEED
	else:
		currentMovementSpeed = DEFAULT_SPEED

func _process(delta):
	playerTag.text = playerName + " (" + str(score) + ")"
	
	# Animation
	
	var changeVector = targetPos - fromPos
	# React instantly to keyboard events for the animation to make game "smooth & reactive"
	if controller.nextVector != Vector2.ZERO and not tagged:
		changeVector = controller.nextVector
	
	if changeVector.x < 0:
		$AnimationPlayer.play("walk_left")
	elif changeVector.x > 0:
		$AnimationPlayer.play("walk_right")
	elif changeVector.y < 0:
		$AnimationPlayer.play("walk_up")
	elif changeVector.y > 0:
		$AnimationPlayer.play("walk_down")
	elif tagged:
		$AnimationPlayer.play("tagged")
	else:
		$AnimationPlayer.stop()
	
	# Movement multiplayer desync fix in case player lags "too much behind fromPos"
	if (position.x < min(fromPos.x, targetPos.x) * GRID_SIZE) || \
		(position.x > max(fromPos.x, targetPos.x) * GRID_SIZE) || \
		(position.y < min(fromPos.y, targetPos.y) * GRID_SIZE) || \
		(position.y > max(fromPos.y, targetPos.y) * GRID_SIZE):
		#print("fix position: ", position / GRID_SIZE, " - ", fromPos, " ", targetPos)
		position = fromPos * GRID_SIZE
	
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


func _on_area_entered(area):
	if not hunter or tagged:
		return
		
	var taggedPlayer = area.get_parent()
	if not taggedPlayer is Player:
		return
	
	# TODO implement tag strategies
	#  [ ] taggedPlayer also gets hunter
	#  [x] switch hunter is switche
	print(self.playerName, " tagged ", taggedPlayer.playerName)
	taggedPlayer.tagged = true
	taggedPlayer.hunter = true
	hunter = false
	score += 1
	taggedPlayer.tag.call_deferred()
	
func tag():
	$Camera2D.shake()
	await get_tree().create_timer(1.0).timeout
	tagged = false
	
@rpc("any_peer", "call_local", "reliable")
func setName(playerName):
	self.playerName = playerName
