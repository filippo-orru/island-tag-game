extends Node2D

@export var player : PackedScene
@export var world : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9064)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)

	load_game()


func _on_connect_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(%To.text, 9064)
	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(load_game) # Loads only if connected to a server
	multiplayer.server_disconnected.connect(server_offline)


func load_game():
	%MainMenu.hide()
	%LocalScenes.add_child(world.instantiate())
	add_player.rpc(multiplayer.get_unique_id())


@rpc("any_peer", "call_local") # Add "call_local" if you also want to spawn a player from the server
func add_player(id):
	var player_instance = player.instantiate()
	player_instance.name = str(id)
	
	player_instance.position = Vector2(0, 0)
	player_instance.playerName = "Player 1"
	player_instance.controller = PlayerKeyboardControllStrategy.new() # TODO fixme for network
	
	
	%SpawnTarget.add_child(player_instance)

@rpc("any_peer")
func remove_player(id):
	if %SpawnTarget.get_node(str(id)):
		%SpawnTarget.get_node(str(id)).queue_free()

func server_offline():
	%Menu.show()
	if %LocalScenes.get_child(0):
		%LocalScenes.get_child(0).queue_free()
