@tool

extends Node

@export var ITEM_TYPE : Items:
	set(value):
		ITEM_TYPE = value
		if Engine.is_editor_hint():
			load_item()

@onready var item_mesh : MeshInstance3D = $RigidBody3D/MeshInstance3D
@onready var item_collision : CollisionShape3D = $RigidBody3D/CollisionShape3D

func load_item():
	item_mesh.mesh = ITEM_TYPE.mesh
	item_collision.scale = ITEM_TYPE.mesh.size

func _ready() -> void:
	load_item()

@rpc("call_local")
func remove_item():
	queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	print("thug fart")
	area.add_item(ITEM_TYPE)
	remove_item.rpc()


func _on_area_3d_area_exited(area: Area3D) -> void:
	print("thug disconnected")
