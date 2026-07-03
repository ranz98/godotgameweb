extends CharacterBody3D

# Single-player web controller: camera-relative WASD, jump (no air control),
# hide-in-shadow (E). No networking.

@export var speed: float = 6.0
@export var jump_velocity: float = 8.0
@export var turn_speed: float = 12.0

@onready var _mesh: Node3D = $Mesh
@onready var _cam_pivot: Node3D = $CameraPivot
@onready var _shadow_detector: Area3D = $ShadowDetector
@onready var _hint: Label = get_tree().get_first_node_in_group("hint_label")

var _hidden: bool = false
var _hide_cam_rotation: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	_handle_hide()

	if _hidden:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := _camera_relative_direction(input_dir)
	if is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	# Airborne: keep takeoff momentum (no air walking).

	if direction != Vector3.ZERO and _mesh:
		var target_yaw := atan2(direction.x, direction.z)
		_mesh.rotation.y = lerp_angle(_mesh.rotation.y, target_yaw, turn_speed * delta)

	move_and_slide()

func _camera_relative_direction(input_dir: Vector2) -> Vector3:
	if input_dir == Vector2.ZERO:
		return Vector3.ZERO
	var basis := _cam_pivot.global_transform.basis
	var forward := -basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := basis.x
	right.y = 0.0
	right = right.normalized()
	return (forward * -input_dir.y + right * input_dir.x).normalized()

func _handle_hide() -> void:
	var in_shadow := _shadow_detector != null and not _shadow_detector.get_overlapping_areas().is_empty()
	if Input.is_action_just_pressed("hide"):
		if _hidden:
			_set_hidden(false)
		elif in_shadow:
			_set_hidden(true)
	if _hint:
		if _hidden:
			_hint.text = "Hidden — press E to reappear   (Esc frees the mouse)"
		elif in_shadow:
			_hint.text = "In shadow — press E to hide"
		else:
			_hint.text = "Click to look • WASD move • Space jump • find a shadow, press E to hide"

func _set_hidden(value: bool) -> void:
	_hidden = value
	if value:
		_hide_cam_rotation = _cam_pivot.rotation
	else:
		_cam_pivot.rotation = _hide_cam_rotation
	if _mesh:
		_mesh.visible = not value
