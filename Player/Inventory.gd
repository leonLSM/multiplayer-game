extends Area3D

@onready var inventory_ui = $InventoryUI/Control
@onready var inventory_ui_grid = $InventoryUI/Control/MarginContainer/ItemGrid
@onready var slot = preload("res://Player/PlayerGUI/slot.tscn")
@onready var player = $"../../.."

#Inventory Variables
var max_inventory_weight = 50
var inventory_weight = 0
var inventory = []
var inventory_open = false

#Interaction Variables
var selected = false
var item : RigidBody3D

func _unhandled_input(_event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("interact") and selected:
		add_item(item.ITEM_TYPE)
		item.remove_item.rpc()
	
	if Input.is_action_just_pressed("inventory"):
		inventory_open = !inventory_open
		inventory_ui.visible = !inventory_ui.visible
		if inventory_open:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		print(inventory)

func add_item(item_type):
	
	if item_type in inventory:
		var stored_item = inventory_ui_grid.get_child(inventory.find(item_type))
		stored_item.set_quantity(1)
	else:
		var new_item = slot.instantiate()
		new_item.type = item_type
		new_item.set_icon(item_type.icon)
		new_item.connect('use_item', use_item)
		inventory_ui_grid.add_child(new_item)
	
	inventory.append(item_type)
	inventory_weight += item_type.weight


func _on_area_entered(area: Area3D) -> void:
	item = area.get_parent()
	selected = true


func _on_area_exited(area: Area3D) -> void:
	selected = false

func use_item(type):
	inventory_weight -= type.weight
	
	var health_gain = type.health_points
	var lost_health = player.max_health - player.health
	
	if health_gain != 0 and lost_health <= health_gain:
		player.health += lost_health
		print(player.health)
