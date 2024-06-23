extends Node2D
class_name GameWorld

const GRID_SIZE = 16

@onready var tile_map: TileMap = $Map/Island
@onready var player_spawn_target = $PlayerSpawnTarget

@onready var coin_scene: PackedScene = load("res://assets/items/Coin.tscn")

var isSinglePlayer: bool = false

@export var player_scene: PackedScene
@export var random_seed: int

func _ready():
	# We only need to spawn players on the server.
	if not isSinglePlayer and multiplayer.is_server():
		_ready_multiplayer()
		
	if isSinglePlayer or multiplayer.is_server():
		_generate_islands(random_seed)

func _ready_multiplayer():
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)

func isSpawnPositionBlocked(spawnPosition: Vector2i, blockedPositions) -> bool:
	for blockedPosition in blockedPositions:
		var difference = spawnPosition - blockedPosition
		var rectDistance = abs(difference.x) + abs(difference.y)
		#print("rectDistance = ", rectDistance, " for ", spawnPosition, " to ", blockedPosition)
		if rectDistance < 3: # 3 to make have space between players
			return true
	return false

func add_player(id: int):
	var player = player_scene.instantiate()

	# Find free space to spawn by just rolling until we have a free position
	var players = $PlayerSpawnTarget.get_children()
	var blockedPositions = []
	for otherPlayer in players:
		blockedPositions.append(otherPlayer.fromPos)
		if otherPlayer.fromPos != otherPlayer.targetPos:
			blockedPositions.append(otherPlayer.targetPos)
	print("blocked positions = ", blockedPositions, " for players ", players)
		
	var spawnPosition = Vector2i.ZERO
	var spreadRadius = 1
	var rng = RandomNumberGenerator.new()
	
	
	while isSpawnPositionBlocked(spawnPosition, blockedPositions):
		spawnPosition = Vector2i(
			rng.randi_range(-int(spreadRadius), int(spreadRadius)),
			rng.randi_range(-int(spreadRadius), int(spreadRadius))
		)
		spreadRadius += 0.1
	player.position = spawnPosition * GRID_SIZE
	
	player.playerId = id

	if id == 1:
		if OS.has_environment("USERNAME"): # WINDOWS
			player.playerName = OS.get_environment("USERNAME")
		elif OS.has_environment("USER"): # UNIX
			player.playerName = OS.get_environment("USER")
		else:
			player.playerName = "Host"
		player.controller = PlayerKeyboardControllStrategy.new()
		player.hunter = true
	else:
		#player.playerName = str(id % 100)
		player.controller = PlayerRemoteControllStrategy.new()
		# Replay previous rpc calls
		for spawnedPlank in spawnedPlanks:
			spawn_plank.rpc_id(id, spawnedPlank["coming_from"], spawnedPlank["position"])

	print("add player (on server) id=", id, ", name=", player.playerName, ", pos=", player.position / GRID_SIZE)
	spawn_player(player)

func _generate_islands(seed: int):
	var random = RandomNumberGenerator.new()
	random.seed = seed

	var worldWidth = ($Map/Boundary/BoundaryCollider/Right.shape.distance + $Map/Boundary/BoundaryCollider/Left.shape.distance) / GRID_SIZE
	var worldHeight = ($Map/Boundary/BoundaryCollider/Top.shape.distance + $Map/Boundary/BoundaryCollider/Bottom.shape.distance) / GRID_SIZE
	
	var worldRadius = min(worldWidth / 2, worldHeight / 2) - 10
	
	var patternIndex = TILESET_PATTERN_ISLANDS[random.randi_range(0, len(TILESET_PATTERN_ISLANDS) - 1)]
	
	var islandPattern = tile_map.tile_set.get_pattern(patternIndex[0])
	var islandBackgroundPattern = tile_map.tile_set.get_pattern(patternIndex[1])
	
	var islandCoords = Vector2i(0, 0)
	while not _has_space_for_island(islandCoords):
		islandCoords = Vector2i(
			random.randi_range(-worldRadius, worldRadius),
			random.randi_range(-worldRadius, worldRadius)
		)
	
	tile_map.set_pattern(TILEMAP_LAYER_ISLAND, islandCoords, islandPattern)
	tile_map.set_pattern(TILEMAP_LAYER_ISLAND_BACKDROP, islandCoords + Vector2i(1, 1), islandBackgroundPattern)
	
	var coin = coin_scene.instantiate()
	coin.position = Vector2((islandCoords + Vector2i(4, 4)) * GRID_SIZE)
	
	$Map/CoinsSpawnTarget.add_child(coin, true)

func _has_space_for_island(coords: Vector2i):
	for offsetX in range(10):
		for offsetY in range(10):
			var offsetCoords = Vector2i(coords.x + offsetX, coords.y + offsetY)
			var isWalkable = get_custom_data_at(TILEMAP_LAYER_ISLAND, offsetCoords, "isWalkable")
			if isWalkable:
				return false
		
	return true

func spawn_player(player: Player):
	$PlayerSpawnTarget.add_child(player, true)


func del_player(id: int):
	if not $PlayerSpawnTarget.has_node(str(id)):
		return
	$PlayerSpawnTarget.get_node(str(id)).queue_free()



func get_tile_data_at(layer: int, position: Vector2i) -> TileData:
	return tile_map.get_cell_tile_data(layer, position)

func get_custom_data_at(layer: int, position: Vector2i, custom_data_name: String) -> Variant:
	var data = get_tile_data_at(layer, position)
	if data == null:
		return null
	return data.get_custom_data(custom_data_name)

func isWalkable(position: Vector2i) -> bool:
	return get_custom_data_at(1, position, "isWalkable") || get_custom_data_at(2, position, "isWalkable")

const TILEMAP_LAYER_ISLAND_BACKDROP = 0
const TILEMAP_LAYER_ISLAND = 1
const TILEMAP_LAYER_PLANKS = 2

const TILESET_TILES_PATHS_AND_OBJECTS = 3

const TILESET_PLANK_HORIZONTAL_COORDS = Vector2i(23, 8)
const TILESET_PLANK_VERTICAL_COORDS = Vector2i(22, 7)
const TILESET_PLANK_JOINT_COORDS = Vector2i(22, 8)

# Index of the island pattern (foreground, background/decoration)
const TILESET_PATTERN_ISLANDS = [
	[0, 2],
	[1, 3],
]

var spawnedPlanks = []

@rpc("any_peer", "call_local", "reliable")
func spawn_plank(coming_from: Vector2i, position: Vector2i) -> void:
	spawnedPlanks.append({"coming_from": coming_from, "position": position})
	
	var plankType
	if coming_from.x != position.x:
		plankType = TILESET_PLANK_HORIZONTAL_COORDS
	else:
		plankType = TILESET_PLANK_VERTICAL_COORDS
	
	tile_map.set_cell(TILEMAP_LAYER_PLANKS, position, TILESET_TILES_PATHS_AND_OBJECTS, plankType)
	
	var neighbors = [
		Vector2i(0, 0), # Self
		
		Vector2i(-1, 0), # Left
		Vector2i(0, -1), # Top
		Vector2i(1, 0), # Right
		Vector2i(0, 1), # Bottom
	]
	for offset in neighbors:
		var coords = position + offset
		_spawn_plank_joints(coords)

func is_plank(coords):
	return coords in [TILESET_PLANK_HORIZONTAL_COORDS, TILESET_PLANK_VERTICAL_COORDS, TILESET_PLANK_JOINT_COORDS]

func has_plank(position: Vector2i) -> bool:
	var coords = tile_map.get_cell_atlas_coords(TILEMAP_LAYER_PLANKS, position)
	return is_plank(coords)

func _spawn_plank_joints(position: Vector2i):
	if not has_plank(position):
		return
	
	var neighbors = [
		Vector2i(-1, 0), # Left
		Vector2i(0, -1), # Top
		Vector2i(1, 0), # Right
		Vector2i(0, 1), # Bottom
		Vector2i(-1, 0), # Left again to complete the loop
	]
	
	var shouldBeAJoint = false
	var plankAtLastNeighbor = false
	for offset in neighbors:
		var coords = position + offset
		var hasPlank = has_plank(coords)
		if plankAtLastNeighbor and hasPlank:
			shouldBeAJoint = true
			break
		plankAtLastNeighbor = hasPlank
	
	if shouldBeAJoint:
		tile_map.set_cell(
			TILEMAP_LAYER_PLANKS, 
			position, 
			TILESET_TILES_PATHS_AND_OBJECTS, 
			TILESET_PLANK_JOINT_COORDS
		)


func _on_multiplayer_spawner_spawned(player):
	if player is Player:
		if player.playerId == multiplayer.get_unique_id():
			player.controller = PlayerKeyboardControllStrategy.new()
			
			if OS.has_environment("USERNAME"): # WINDOWS
				player.setName.rpc(OS.get_environment("USERNAME"))
			elif OS.has_environment("USER"): # UNIX
				player.setName.rpc(OS.get_environment("USER"))
			else:
				player.setName.rpc("Player " + str(player.playerId % 100))
				
			print("spawned own")
		else:
			player.controller = PlayerRemoteControllStrategy.new()
			player.get_node("Camera2D").set_enabled(false)
			print("spawned other player: ", player.playerId % 100)

