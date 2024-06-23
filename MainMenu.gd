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

	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_disconnected.connect(remove_player)

	load_game()


func _on_connect_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	var ip = %IpAddress.text
	if ip == "":
		ip = "localhost"
	peer.create_client(ip, 9064)

	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(load_game) # Loads only if connected to a server
	multiplayer.server_disconnected.connect(server_offline)


func load_game():
	%MainMenu.hide()
	%MenuCamera.set_enabled(false)
	%LocalScenes.add_child(world.instantiate())
	add_player.rpc(multiplayer.get_unique_id())


@rpc("any_peer", "call_local") # Add "call_local" if you also want to spawn a player from the server
func add_player(id):
	var player = player.instantiate()
	player.set_multiplayer_authority(id)
	
	player.position = Vector2(0, 0) # TODO based on ID
	print(get_tree())
	
	if id == multiplayer.get_unique_id():
		player.playerName = "Me"
		player.controller = PlayerKeyboardControllStrategy.new()
	
	else:
		player.playerName = "Player 2"
		player.get_node("Camera2D").set_enabled(false)
		player.controller = PlayerRemoteControllStrategy.new()

	
	%SpawnTarget.add_child(player)

@rpc("any_peer")
func remove_player(id):
	if %SpawnTarget.get_node(str(id)):
		%SpawnTarget.get_node(str(id)).queue_free()

func server_offline():
	%Menu.show()
	if %LocalScenes.get_child(0):
		%LocalScenes.get_child(0).queue_free()


func _on_singleplayer_button_pressed():
	%MainMenu.hide()
	%MenuCamera.set_enabled(false)
	%SpawnTarget.add_child(world.instantiate())
	
	var player1 = player.instantiate()
	player1.position = Vector2(0, 0)
	player1.playerName = "Me"
	player1.controller = PlayerKeyboardControllStrategy.new()
	%SpawnTarget.add_child(player1)
	
	var bot1 = player.instantiate()
	bot1.position = Vector2(32, 32)
	bot1.playerName = "Bot 1"
	bot1.get_node("Camera2D").set_enabled(false)
	bot1.controller = PlayerBotControllStrategy.new()
	%SpawnTarget.add_child(bot1)
