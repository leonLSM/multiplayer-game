extends MultiplayerSpawner

@onready var item_scene = preload("res://Items/item.tscn")
@export var spawn_location : Node3D

func _init() -> void:
	spawn_function = spawn_custom

func spawn_custom(data: Variant) -> Node:
	var item = item_scene.instantiate()
	item.ITEM_TYPE = load("res://Items/Medkit/Medkit.tres")
	item.spawn_location = spawn_location
	print("ducks")
	
	return item
	
