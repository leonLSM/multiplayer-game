@tool

extends RigidBody3D

@export var ITEM_TYPE : Items:
	set(value):
		ITEM_TYPE = value
		if Engine.is_editor_hint():
			load_item()

@onready var item_mesh : MeshInstance3D = $ItemMesh
@onready var item_collision : CollisionShape3D = $ItemCollision
@onready var spawn_location : Node3D

func load_item():
	item_mesh.mesh = ITEM_TYPE.mesh
	item_collision.scale = ITEM_TYPE.mesh.size

func _ready() -> void:
	if ITEM_TYPE != null:
		load_item()
		position = spawn_location.position
		print("ready")

@rpc("call_local", "any_peer")
func remove_item():
	queue_free()
