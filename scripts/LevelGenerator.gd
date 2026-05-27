extends Node3D

@export var player_path: NodePath
@export var segment_library_path: NodePath
@export var segment_world_length: float = 24.0
@export var visible_segments_ahead: int = 8
@export var keep_segments_behind: int = 2

var _player: Node3D
var _next_segment_index: int = 0
var _spawned_segments: Array[Node3D] = []
var _segment_templates: Array[Node3D] = []

func _ready() -> void:
randomize()
_player = get_node_or_null(player_path) as Node3D

var segment_library := get_node_or_null(segment_library_path)
if segment_library != null:
for child in segment_library.get_children():
if child is Node3D:
_segment_templates.append((child as Node3D).duplicate())
segment_library.queue_free()

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
if _segment_templates.is_empty():
return

var template := _segment_templates[randi() % _segment_templates.size()]
var segment := template.duplicate() as Node3D
segment.name = "Segment_%d" % segment_index
segment.position.z = -segment_index * _segment_world_length()
add_child(segment)
_spawned_segments.append(segment)

_next_segment_index = segment_index + 1

func _prune_old_segments(player_segment: int) -> void:
while not _spawned_segments.is_empty():
var first_segment := _spawned_segments[0]
var first_index := int(first_segment.name.get_slice("_", 1))
if first_index >= player_segment - keep_segments_behind:
break
_spawned_segments.pop_front()
first_segment.queue_free()

func _segment_world_length() -> float:
return segment_world_length
