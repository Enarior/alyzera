class_name MainGame
extends Node
##########################################
## Scene loading and high level systems ##
##########################################

const PLAYER_SCENE_UID : String = "uid://ccmaxn3cpfig0"
const LEVEL_00_UID : String  = "uid://sfta3f464c6g"

# Game World root nodes

@onready var level_root: Node3D = $World/LevelRoot
@onready var entity_root: Node3D = $World/EntityRoot
@onready var effect_root: Node3D = $World/EffectRoot

var player : Player = null

var _current_level : BaseLevel = null

# UI Root Nodes (FUTURE)
#@onready var hud_root        : Control = %HudRoot
#@onready var pause_root      : Control = %PauseRoot
#@onready var transition_root : Control = %TransitionRoot

func _ready() -> void:
	_init_player()

	load_level(LEVEL_00_UID)
	
	Global.change_level.connect(load_level)


## Called for loading a level scene.
## NOTE: The input level_scene must extend BaseLevel
func load_level(level_scene : String) -> void:
	# Make sure this is called during idle time
	_deferred_load_level.call_deferred(level_scene)

func _deferred_load_level(level_scene_uid : String) -> void:
	if _current_level != null:
		_current_level.queue_free()
		_current_level = null
		# Allow the old level to finish freeing before adding the new one
		await get_tree().process_frame

	var new_level_packed : PackedScene =\
		ResourceLoader.load(level_scene_uid, "PackedScene") as PackedScene
	if new_level_packed == null:
		push_error("Could not load level as a packed scene: " + level_scene_uid)
		return
		
	var new_level = new_level_packed.instantiate()
	
	if not new_level : 
		push_error("Could not instantiate new level " + level_scene_uid)
		return

	if not new_level is BaseLevel :
		new_level.free()
		push_error("Loaded level is not of type BaseLevel " + level_scene_uid)
		return
		# FUTURE (main menu): Should have a fall back scene

	_current_level = new_level as BaseLevel

	level_root.add_child(_current_level)

	_place_player_at_level_spawn()
	_spawn_npcs()
	#_setup_level_camera()


## Instantiates the player and adds it to the entity layer
func _init_player() -> void:
	var player_scene : PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_UID)
		return

	player = player_scene.instantiate() as Player
	if player == null:
		push_error("Loaded player scene does not extend player or DNE: " + PLAYER_SCENE_UID)
		return

	entity_root.add_child(player)
	%TurnManager.add_unit(player) # TEMP



## Finds the default spawn location in currently loaded level, and places
##  the Player at that position.
func _place_player_at_level_spawn() -> void:
	if player == null:
		push_error("Cannot place player in level because it is null")
		return
	if _current_level == null:
		push_error("Cannot place player into level because level is null")
		return

	player.global_position = _current_level.get_default_player_spawn()

func _spawn_npcs():
	var spawns = _current_level.get_npc_spawns()


	for spawn in spawns:
		spawn_npc(spawn)


func spawn_npc(spawn: Marker3D):
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
		npc.vision_entered.connect(%TurnManager.initialize)
		%TurnManager.add_unit(npc) # TEMP
	elif "passive_npc" in node_groups:
		npc = npc_scene.instantiate() as PassiveNpc
	
	if npc == null:
		push_error("Loaded npc scene does not extend NPc or DNE: " + npc_scene_uid)
		return
	
	
	entity_root.add_child(npc)
	npc.global_position = spawn.global_position

## Attaches player to the current camera as the target
func _setup_level_camera() -> void:
	if player == null or _current_level == null:
		return

	var level_camera : Camera3D = _current_level.get_player_camera()
	if level_camera == null:
		return

	# FUTURE (camera): Temporary hookup
	# Will become: camera_system.set_target(player)
	level_camera.target = player


func _init_systems() -> void:
	pass # FUTURE (systems): Will be called to set up high level systems
