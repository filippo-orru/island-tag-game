extends Node2D
class_name GameWorld

const GRID_SIZE = 16

@onready var tile_map: TileMap = $Map/Island

static var _instance: GameWorld = null

var _player_scene = preload("res://player/player.tscn")

func _ready():
	_instance = self if _instance == null else _instance
	
	return
	
	var player: Player = _player_scene.instantiate()
	player.position = Vector2(0, 0)
	if is_multiplayer_authority():
		player.playerName = "Me"
		player.controller = PlayerKeyboardControllStrategy.new()
	
	else:
		player.playerName = "Player 2"
		player.controller = PlayerKeyboardControllStrategy.new()
	add_child(player)
	
	var bot1: Player = _player_scene.instantiate()
	bot1.position = Vector2(2 * GameWorld.GRID_SIZE, 2 * GameWorld.GRID_SIZE)
	bot1.playerName = "Bot 1"
	bot1.controller = PlayerBotControllStrategy.new()
	bot1.get_node("Camera2D").set_enabled(false)
	add_child(bot1)

static func get_tile_data_at(layer: int, position: Vector2i) -> TileData:
	return _instance.tile_map.get_cell_tile_data(layer, position)

static func get_custom_data_at(layer: int, position: Vector2i, custom_data_name: String) -> Variant:
	var data = get_tile_data_at(layer, position)
	if data == null:
		return null
	return data.get_custom_data(custom_data_name)

static func isWalkable(position: Vector2i) -> bool:
	return get_custom_data_at(1, position, "isWalkable") || get_custom_data_at(2, position, "isWalkable")

const TILEMAP_LAYER_PLANKS = 2

const TILESET_TILES_PATHS_AND_OBJECTS = 3

const TILESET_PLANK_HORIZONTAL_COORDS = Vector2i(23, 8)
const TILESET_PLANK_VERTICAL_COORDS = Vector2i(22, 7)
const TILESET_PLANK_JOINT_COORDS = Vector2i(22, 8)

static func spawn_plank(coming_from: Vector2i, position: Vector2i) -> void:
	var plankType
	if coming_from.x != position.x:
		plankType = TILESET_PLANK_HORIZONTAL_COORDS
	else:
		plankType = TILESET_PLANK_VERTICAL_COORDS
	
	_instance.tile_map.set_cell(TILEMAP_LAYER_PLANKS, position, TILESET_TILES_PATHS_AND_OBJECTS, plankType)
	
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

static func is_plank(coords):
	return coords in [TILESET_PLANK_HORIZONTAL_COORDS, TILESET_PLANK_VERTICAL_COORDS, TILESET_PLANK_JOINT_COORDS]

static func has_plank(position: Vector2i) -> bool:
	var coords = _instance.tile_map.get_cell_atlas_coords(TILEMAP_LAYER_PLANKS, position)
	return is_plank(coords)

static func _spawn_plank_joints(position: Vector2i):
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
		_instance.tile_map.set_cell(
			TILEMAP_LAYER_PLANKS, 
			position, 
			TILESET_TILES_PATHS_AND_OBJECTS, 
			TILESET_PLANK_JOINT_COORDS
		)
