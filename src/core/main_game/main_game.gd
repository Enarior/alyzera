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
var _paused : bool = false

# UI Root Nodes (FUTURE)
#@onready var hud_root        : Control = %HudRoot
@onready var pause_root      : Control = %PauseRoot
#@onready var transition_root : Control = %TransitionRoot

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	#_init_player()

	_load_level(LEVEL_00_UID, false)
	
	Global.change_level.connect(_load_level)
	$MultiplayerSpawner.player_spawned.connect(_init_player)
	
func _input(event:InputEvent):
	if Input.is_action_just_pressed("pause"):
		if not _paused:
			pause_root.show()
			_paused = true
			Input.call_deferred("set_mouse_mode",Input.MOUSE_MODE_VISIBLE)

		else :
			pause_root.hide()
			_paused = false
			Input.call_deferred("set_mouse_mode",Input.MOUSE_MODE_CAPTURED)



## Called for loading a level scene.
## NOTE: The input level_scene must extend BaseLevel
func _load_level(level_scene : String, player_exists: bool) -> void:
	#if not OS.has_feature("server"): return
	# Make sure this is called during idle time
	_deferred_load_level.call_deferred(level_scene, player_exists)

func _deferred_load_level(level_scene_uid : String, player_exists_: bool) -> void:
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
	

	if player_exists_ :
		_place_player_at_level_spawn()
	#_setup_level_camera()


## Instantiates the player and adds it to the entity layer
func _init_player(spawned_player: Node3D) -> void:
	player = spawned_player
	call_deferred("_place_player_at_level_spawn")
	
## Finds the default spawn location in currently loaded level, and places
##  the Player at that position.
func _place_player_at_level_spawn() -> void:
	if ! is_multiplayer_authority():return
	if player == null:
		push_error("Cannot place player in level because it is null")
		return
	if _current_level == null:
		push_error("Cannot place player into level because level is null")
		return

	var new_pos = _current_level.get_default_player_spawn()
	player.global_position = new_pos
	print("changing pos")

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


func _on_server_button_pressed() -> void:
	pass # Replace with function body.
