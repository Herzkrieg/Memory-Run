extends Node3D

@export var fail_height: float = -5.0
@export var camera_offset := Vector3(0.0, 8.0, 14.0)

@onready var _player: CharacterBody3D = $Player
@onready var _camera: Camera3D = $Camera3D

func _process(_delta: float) -> void:
if _player.global_position.y < fail_height:
_reset_player()

_camera.global_position = _player.global_position + camera_offset
_camera.look_at(_player.global_position + Vector3(0.0, 1.2, -12.0), Vector3.UP)

func _reset_player() -> void:
_player.global_position = Vector3(0.0, 2.0, 0.0)
_player.velocity = Vector3.ZERO
