extends MultiplayerSpawner

var PLAYER_SCENE_UID: String = "uid://ccmaxn3cpfig0"

signal player_spawned

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)
	HighLevelNetworkHandler.server_started.connect(spawn_player)
	

func spawn_player(id: int=1) -> void:
	print("multiplayer.peer_connected, id : ", id)
	if !multiplayer.is_server(): return
	print("multiplayer.is_server TRUE ", id)
	
	var player_scene : PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_UID)
		return

	var player = player_scene.instantiate() as Player
	if player == null:
		push_error("Loaded player scene does not extend player or DNE: " + PLAYER_SCENE_UID)
		return

	# Node name is synchronized through MultiplayerSpawner, we can use this to set authority to the player.
	player.name = str(id)

	get_node(spawn_path).call_deferred("add_child", player)
	player_spawned.emit(player)
 
