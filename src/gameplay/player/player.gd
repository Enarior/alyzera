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

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	$Pivot/IdLabel.text = name
	$Pivot/MeshInstance3D.get_surface_override_material(0).albedo_color = Color(randf(),randf(), randf(),1) 
	Input.call_deferred("set_mouse_mode",Input.MOUSE_MODE_CAPTURED)
	
	%PlayerCamera.current = is_multiplayer_authority()
	
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		set_process_input(false)

	print("created player with id : ", name)
	

func _process(_delta: float) -> void:
	if multiplayer and ! is_multiplayer_authority(): return
	input_dir = Input.get_vector("strafe_left", "strafe_right", "backward", "forward")

func _physics_process(delta: float) -> void:
	if ! is_multiplayer_authority(): return
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
	if ! is_multiplayer_authority(): return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity) # PI 3.14 => 180 degrees 
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, MAX_ANGLE_LOOK_DOWN, MAX_ANGLE_LOOK_UP)
	
	
	if Input.is_action_just_pressed("toggle_mouse_mode"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func check_jump_input() -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

func process_gravity() -> void:
	if not is_on_floor():
		velocity.y -= gravity
