extends MultiplayerSynchronizer


func _ready():
		set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass # TODO
