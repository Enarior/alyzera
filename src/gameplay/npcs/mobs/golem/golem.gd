extends MobNpc
class_name Golem

signal vision_entered

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

var target : Node3D


func _physics_process(delta: float) -> void:
	if target:
		velocity = position.direction_to(target.position)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func play_turn():
	await get_tree().create_timer(2).timeout


func _on_vision_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		vision_entered.emit()
		print(" golem vision entered")


func _on_vision_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = null
