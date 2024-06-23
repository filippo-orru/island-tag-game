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
func change_level(scene: PackedScene, isSinglePlayer: bool):
	for child in $LevelSpawnTarget.get_children():
		%LevelSpawnTarget.remove_child(child)
		child.queue_free()
	
	var world: GameWorld = scene.instantiate()
	world.isSinglePlayer = isSinglePlayer
	$LevelSpawnTarget.add_child(world)
	singlePlayer_PlayerInit.call_deferred(world)

# The server can restart the level by pressing F5.
func _input(event):
	if not multiplayer.is_server():
		return
	if event.is_action("ui_filedialog_refresh") and Input.is_action_just_pressed("ui_filedialog_refresh"):
		change_level.call_deferred(load("res://world.tscn"))

func server_offline():
	%MainMenu.show()
	for child in %LevelSpawnTarget.get_children():
		%LevelSpawnTarget.remove_child(child)
		child.queue_free()


func _on_singleplayer_button_pressed():
	load_game(true, true)
	
func singlePlayer_PlayerInit(world: GameWorld):
	var player1 = player.instantiate()
	player1.position = Vector2(0, 0)
	player1.playerName = "Me"
	player1.controller = PlayerKeyboardControllStrategy.new()
	world.spawn_player(player1)

	var bot1 = player.instantiate()
	bot1.position = Vector2(32, 32)
	bot1.playerName = "Bot 1"
	bot1.get_node("Camera2D").set_enabled(false)
	bot1.hunter = true
	var botController: PlayerBotControllStrategy = PlayerBotControllStrategy.new()
	botController.targetPlayer = player1
	bot1.controller = botController
	world.spawn_player(bot1)
