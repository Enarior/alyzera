class_name Player
extends CharacterBody3D

const MAX_ANGLE_LOOK_UP := deg_to_rad(50)
const MAX_ANGLE_LOOK_DOWN := deg_to_rad(-50)

@export var acceleration: float = 30.0
@export var jump_force: float = 12.0
@export var gravity: float = 0.98
@export var mouse_sensitivity: float = 0.002
@export var run_speed: float = 6.0
@export var walk_speed: float = 3.0


@onready var camera: Camera3D = %PlayerCamera

var input_dir := Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta: float) -> void:
	input_dir = Input.get_vector("strafe_left", "strafe_right", "backward", "forward")


func _physics_process(delta: float) -> void:
	check_jump_input()
	process_gravity()
	
	var input_3d_space := Vector3(input_dir.x, 0, -input_dir.y)
	var target_speed := run_speed if Input.is_action_pressed("run") else walk_speed
	var desired_velocity := transform.basis * input_3d_space * target_speed
	if input_3d_space == Vector3.ZERO:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, desired_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, desired_velocity.z, acceleration * delta)
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity) # PI 3.14 => 180 degrees 
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, MAX_ANGLE_LOOK_DOWN, MAX_ANGLE_LOOK_UP)


func check_jump_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force


func process_gravity() -> void:
	if not is_on_floor():
		velocity.y -= gravity

func play_turn():
	await get_tree().create_timer(2).timeout
