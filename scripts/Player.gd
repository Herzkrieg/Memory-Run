extends CharacterBody3D

@export var forward_speed: float = 12.0
@export var horizontal_speed: float = 18.0
@export var horizontal_limit: float = 4.0
@export var gravity: float = 35.0
@export var touch_sensitivity: float = 3.0

var _touch_active := false
var _touch_last_x: float = 0.0
var _touch_axis: float = 0.0

@onready var _ball_mesh: MeshInstance3D = $BallMesh

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_touch_active = true
			_touch_last_x = touch.position.x
		else:
			_touch_active = false
			_touch_axis = 0.0
	elif event is InputEventScreenDrag and _touch_active:
		var drag := event as InputEventScreenDrag
		_update_touch_axis(drag.position.x)
	elif event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			_touch_active = mouse_button.pressed
			_touch_last_x = mouse_button.position.x
			if not _touch_active:
				_touch_axis = 0.0
	elif event is InputEventMouseMotion and _touch_active:
		var mouse_motion := event as InputEventMouseMotion
		_update_touch_axis(mouse_motion.position.x)

func _physics_process(delta: float) -> void:
	var keyboard_axis := Input.get_axis("ui_left", "ui_right")
	var horizontal_axis := clamp(keyboard_axis + _touch_axis, -1.0, 1.0)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	velocity.z = -forward_speed
	position.x = clamp(position.x + (horizontal_axis * horizontal_speed * delta), -horizontal_limit, horizontal_limit)

	move_and_slide()
	_roll_visual(delta)
	_touch_axis = 0.0

func _update_touch_axis(current_x: float) -> void:
	var viewport_width := max(get_viewport().get_visible_rect().size.x, 1.0)
	var normalized_delta := (current_x - _touch_last_x) / viewport_width
	_touch_axis = normalized_delta * touch_sensitivity
	_touch_last_x = current_x

func _roll_visual(delta: float) -> void:
	if _ball_mesh == null:
		return

	_ball_mesh.rotate_x(-forward_speed * delta)
