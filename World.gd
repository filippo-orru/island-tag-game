extends Node2D
class_name GameWorld

const GRID_SIZE = 16

@onready var tile_map: TileMap = $Map/Island

var isSinglePlayer: bool = false

@export var player_scene: PackedScene

func _ready():
	# We only need to spawn players on the server.
	if isSinglePlayer or not multiplayer.is_server():
		return

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


func add_player(id: int):
	print("add player (on server) ", id)
	var player = player_scene.instantiate()

	player.position = Vector2(0, 0)
	player.playerId = id

	if id == 1:
		player.playerName = "Host"
		player.controller = PlayerKeyboardControllStrategy.new()
	else:
		player.playerName = str(id % 100)
		player.controller = PlayerRemoteControllStrategy.new()

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

const TILEMAP_LAYER_PLANKS = 2

const TILESET_TILES_PATHS_AND_OBJECTS = 3

const TILESET_PLANK_HORIZONTAL_COORDS = Vector2i(23, 8)
const TILESET_PLANK_VERTICAL_COORDS = Vector2i(22, 7)
const TILESET_PLANK_JOINT_COORDS = Vector2i(22, 8)

@rpc("any_peer", "call_local", "reliable")
func spawn_plank(coming_from: Vector2i, position: Vector2i) -> void:
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
			print("spawned own player")
		else:
			player.controller = PlayerRemoteControllStrategy.new()
			player.get_node("Camera2D").set_enabled(false)
			print("spawned other player: ", player.playerId % 100)

