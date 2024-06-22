extends TileMap


@onready var activeCamera: Camera2D = get_viewport().get_camera_2d()

func _process(delta):
	self.position.x = int(activeCamera.position.x) / GameWorld.GRID_SIZE
	self.position.y = int(activeCamera.position.y) / GameWorld.GRID_SIZE
	print(self.position.x, self.position.y)
