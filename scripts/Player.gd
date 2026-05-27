extends CharacterBody3D

@export var forward_speed: float = 12.0
@export var lane_width: float = 4.0
@export var lane_change_speed: float = 16.0
@export var gravity: float = 35.0
@export var swipe_threshold: float = 60.0

var _target_lane: int = 0
var _swipe_origin := Vector2.ZERO
var _swipe_active := false

@onready var _ball_mesh: MeshInstance3D = $BallMesh

func _unhandled_input(event: InputEvent) -> void:
if event is InputEventScreenTouch:
if event.pressed:
_swipe_origin = event.position
_swipe_active = true
else:
_process_swipe(event.position)
_swipe_active = false
elif event is InputEventScreenDrag and _swipe_active:
_process_swipe(event.position)

func _physics_process(delta: float) -> void:
if Input.is_action_just_pressed("ui_left"):
_shift_lane(-1)
if Input.is_action_just_pressed("ui_right"):
_shift_lane(1)

if not is_on_floor():
velocity.y -= gravity * delta
else:
velocity.y = 0.0

velocity.z = -forward_speed
position.x = move_toward(position.x, _target_lane * lane_width, lane_change_speed * delta)

move_and_slide()
_roll_visual(delta)

func _process_swipe(position: Vector2) -> void:
var swipe_delta: Vector2 = position - _swipe_origin
if absf(swipe_delta.x) < swipe_threshold:
return

_shift_lane(1 if swipe_delta.x > 0.0 else -1)
_swipe_origin = position

func _shift_lane(direction: int) -> void:
_target_lane = clamp(_target_lane + direction, -1, 1)

func _roll_visual(delta: float) -> void:
if _ball_mesh == null:
return

_ball_mesh.rotate_x(-forward_speed * delta)
