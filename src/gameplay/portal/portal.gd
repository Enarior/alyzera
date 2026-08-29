extends Node

signal portal_entered

## 
var destination_level_uid: String

	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Global.change_level.emit(destination_level_uid)
		print("portal to " + destination_level_uid)
