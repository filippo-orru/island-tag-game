extends TileMap


@onready var activeCamera: Camera2D = get_viewport().get_camera_2d()

func _process(delta):
	if activeCamera == null:
		# Player is not instantiated yet
		return

	var x = int(activeCamera.global_position.x) / GameWorld.GRID_SIZE / 2
	var y = int(activeCamera.global_position.y) / GameWorld.GRID_SIZE / 2
	
	self.position.x = x * GameWorld.GRID_SIZE * 2
	self.position.y = y * GameWorld.GRID_SIZE * 2
