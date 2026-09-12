extends Control

const VERSION_SETTING : String = "application/config/version"

@onready var fps_label    : Label = %FpsLabel
@onready var version_info_label : Label = %VersionInfoLabel
@onready var instance_type_label: Label = %InstanceTypeLabel


func _ready() -> void:
	_add_version()
	_add_instance_type()

func _process(delta: float) -> void:
	fps_label.set_text("FPS: " + str(Engine.get_frames_per_second()))

func _add_version() -> void:
	var version_str : String = ProjectSettings.get_setting(VERSION_SETTING)
	version_info_label.text += version_str

func _add_instance_type() -> void:
	if OS.has_feature("server"):
		instance_type_label.text = "Server"
	else:
		instance_type_label.text = "Client"
		
	
