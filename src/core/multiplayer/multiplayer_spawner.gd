extends MultiplayerSpawner

var PLAYER_SCENE_UID: String = "uid://ccmaxn3cpfig0"

signal player_spawned

@onready var entity_root: Node3D = $"../World/EntityRoot"


func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)
	HighLevelNetworkHandler.server_started.connect(spawn_player)
	

func spawn_player(id: int=1) -> void:
	if !multiplayer.is_server(): return
	
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


func spawn_npc(spawn: Marker3D):
	if !multiplayer.is_server(): return
	
	var npc_scene_uid = spawn.npc_scene_uid
	var npc_scene : PackedScene = ResourceLoader.load(npc_scene_uid) as PackedScene
	
	if npc_scene == null:
		push_error("Could not load npc scene: " + npc_scene_uid)
		return

	var npc = null
	var state = npc_scene.get_state()
	var node_groups = state.get_node_groups(0)


	if "mob_npc" in node_groups:
		npc = npc_scene.instantiate() as MobNpc
		npc.vision_entered.connect(%CombatManager.start_combat)
	
		%TurnManager.add_unit(npc) # TEMP
		
	elif "passive_npc" in node_groups:
		npc = npc_scene.instantiate() as PassiveNpc
	
	if npc == null:
		push_error("Loaded npc scene does not extend NPc or DNE: " + npc_scene_uid)
		return
	
	entity_root.add_child(npc)
	npc.global_position = spawn.global_position
