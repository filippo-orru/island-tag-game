extends Node2D

@export var player : PackedScene
@export var world : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		_on_host_button_pressed.call_deferred()


func _on_host_button_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9064)

	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return

	multiplayer.multiplayer_peer = peer

	load_game(true, false)


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
	load_game(false, false)

	multiplayer.server_disconnected.connect(server_offline)


func load_game(loadMap: bool, singlePlayer = false):
	%MainMenu.hide()

	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if loadMap:
		change_level.call_deferred(load("res://world.tscn"), singlePlayer)

# Call this function deferred and only on the main authority (server).
func change_level(scene: PackedScene, isSinglePlayer):
	for child in $LevelSpawnTarget.get_children():
		%LevelSpawnTarget.remove_child(child)
		child.queue_free()
	var instance = scene.instantiate()
	instance.isSinglePlayer = isSinglePlayer
	$LevelSpawnTarget.add_child(instance)

# The server can restart the level by pressing F5.
func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("ui_filedialog_refresh") and Input.is_action_just_pressed("ui_filedialog_refresh"):
		change_level.call_deferred(load("res://world.tscn"))

#@rpc("any_peer", "call_local") # Add "call_local" if you also want to spawn a player from the server
#func add_player(id):
	#var player = player.instantiate()
	#player.set_multiplayer_authority(id)
	#
	#player.position = Vector2(0, 0) # TODO based on ID
	#print(get_tree())
	#
	#if id == multiplayer.get_unique_id():
		#player.playerName = "Me"
		#player.controller = PlayerKeyboardControllStrategy.new()
	#
	#else:
		#player.playerName = "Player 2"
		#player.get_node("Camera2D").set_enabled(false)
		#player.controller = PlayerRemoteControllStrategy.new()
#
	#
	#%SpawnTarget.add_child(player)
#
##@rpc("any_peer")
#func remove_player(id):
	#if %SpawnTarget.get_node(str(id)):
		#%SpawnTarget.get_node(str(id)).queue_free()

func server_offline():
	%MainMenu.show()
	for child in %LevelSpawnTarget.get_children():
		%LevelSpawnTarget.remove_child(child)
		child.queue_free()


func _on_singleplayer_button_pressed():
	load_game(true, true)
	singlePlayer_PlayerInit.call_deferred()
	
func singlePlayer_PlayerInit():
	var player1 = player.instantiate()
	player1.position = Vector2(0, 0)
	player1.playerName = "Me"
	player1.controller = PlayerKeyboardControllStrategy.new()
	%LevelSpawnTarget.add_child(player1)

	var bot1 = player.instantiate()
	bot1.position = Vector2(32, 32)
	bot1.playerName = "Bot 1"
	bot1.get_node("Camera2D").set_enabled(false)
	var botController: PlayerBotControllStrategy = PlayerBotControllStrategy.new()
	botController.targetPlayer = player1
	bot1.controller = botController
	%LevelSpawnTarget.add_child(bot1)
