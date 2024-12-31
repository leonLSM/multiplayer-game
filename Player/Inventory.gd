extends Area3D

@onready var inventory_ui = $InventoryUI/Control
@onready var slot = preload("res://Player/PlayerGUI/slot.tscn")

#Inventory Variables
var max_inventory_weight = 50
var inventory_weight = 0
var inventory = []

#Interaction Variables
var selected = false
var item : RigidBody3D

func _unhandled_input(_event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("interact") and selected:
		add_item(item.ITEM_TYPE)
		item.remove_item.rpc()
	
	if Input.is_action_just_pressed("inventory"):
		inventory_ui.visible = !inventory_ui.visible
		print(inventory)

func add_item(item_type):
	inventory.append(item_type)
	inventory_weight += item_type.weight
	var new_item = slot.instantiate()
	inventory_ui.add_child(new_item)


func _on_area_entered(area: Area3D) -> void:
	item = area.get_parent()
	selected = true


func _on_area_exited(area: Area3D) -> void:
	selected = false
