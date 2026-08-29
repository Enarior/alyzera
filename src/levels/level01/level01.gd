extends BaseLevel

@onready var player_spawn: Marker3D = $Entities/PlayerSpawn
@onready var portal: Area3D = $Entities/Portal

func _ready() -> void:
	portal.destination_level_uid = "uid://sfta3f464c6g"
	portal.get_node("Label3D").text = "Level00"


	
func get_default_player_spawn() -> Vector3:
	return player_spawn.global_position
