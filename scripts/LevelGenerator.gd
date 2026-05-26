extends Node3D

@export var player_path: NodePath
@export var lane_width: float = 4.0
@export var cube_size: float = 2.0
@export var segment_length: int = 12
@export var visible_segments_ahead: int = 8
@export var keep_segments_behind: int = 2

var _player: Node3D
var _next_segment_index: int = 0
var _spawned_segments: Array[Node3D] = []

func _ready() -> void:
randomize()
_player = get_node_or_null(player_path) as Node3D
for i in range(visible_segments_ahead):
_spawn_segment(i)

func _process(_delta: float) -> void:
if _player == null:
return

var traveled_segments: int = int(floor(absf(_player.global_position.z) / _segment_world_length()))
var required_segment: int = traveled_segments + visible_segments_ahead
while _next_segment_index <= required_segment:
_spawn_segment(_next_segment_index)

_prune_old_segments(traveled_segments)

func _spawn_segment(segment_index: int) -> void:
var segment := Node3D.new()
segment.name = "Segment_%d" % segment_index
add_child(segment)
_spawned_segments.append(segment)

var z_start: float = -segment_index * _segment_world_length()
for z_step in range(segment_length):
var hole_lane: int = _pick_hole_lane()
for lane in range(-1, 2):
if lane == hole_lane:
continue
_spawn_cube(segment, lane, z_start - (z_step * cube_size))

_next_segment_index = segment_index + 1

func _spawn_cube(parent: Node3D, lane: int, z_pos: float) -> void:
var body := StaticBody3D.new()
body.position = Vector3(lane * lane_width, -0.5, z_pos)
parent.add_child(body)

var shape := CollisionShape3D.new()
var box_shape := BoxShape3D.new()
box_shape.size = Vector3(cube_size, 1.0, cube_size)
shape.shape = box_shape
body.add_child(shape)

var mesh := MeshInstance3D.new()
var box_mesh := BoxMesh.new()
box_mesh.size = Vector3(cube_size, 1.0, cube_size)
mesh.mesh = box_mesh
mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
body.add_child(mesh)

func _pick_hole_lane() -> int:
if randf() < 0.75:
return 2
return randi_range(-1, 1)

func _prune_old_segments(player_segment: int) -> void:
while not _spawned_segments.is_empty():
var first_segment := _spawned_segments[0]
var first_index := int(first_segment.name.get_slice("_", 1))
if first_index >= player_segment - keep_segments_behind:
break
_spawned_segments.pop_front()
first_segment.queue_free()

func _segment_world_length() -> float:
return segment_length * cube_size
