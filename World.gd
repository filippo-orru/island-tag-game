extends Node2D
class_name World

@onready var tile_map: TileMap = $Map/Island

static var _instance: World = null

func _ready():
	_instance = self if _instance == null else _instance


static func get_tile_data_at(layer: int, position: Vector2i) -> TileData:
	return _instance.tile_map.get_cell_tile_data(layer, position)

static func get_custom_data_at(layer: int, position: Vector2i, custom_data_name: String) -> Variant:
	var data = get_tile_data_at(layer, position)
	if data == null:
		return null
	return data.get_custom_data(custom_data_name)

static func isWalkable(position: Vector2i) -> bool:
	return get_custom_data_at(1, position, "isWalkable") || get_custom_data_at(2, position, "isWalkable")
	
static func spawn_plank(position: Vector2i):
	# Layer 2 is Planks
	_instance.tile_map.set_cell(2, position, 3, Vector2i(23, 8), 0)
