extends Control

const VERSION_SETTING : String = "application/config/version"

@onready var fps_label    : Label = %FpsLabel
@onready var version_info : Label = %VersionInfo

func _ready() -> void:
	_add_version_to_info_label()

func _process(delta: float) -> void:
	fps_label.set_text("FPS: " + str(Engine.get_frames_per_second()))

func _add_version_to_info_label() -> void:
	var version_str : String = ProjectSettings.get_setting(VERSION_SETTING)
	version_info.text += version_str

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("debug_play_turn") and not %TurnManager.turn_playing:
		%TurnManager.play_turn()
