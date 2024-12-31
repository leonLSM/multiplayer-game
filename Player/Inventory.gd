extends Area3D

#Inventory Variables
var max_inventory_weight = 50
var inventory_weight = 0
var inventory = []

func add_item(item_type):
	inventory.append(item_type)
	inventory_weight += item_type.weight
	print(inventory)
	print(inventory_weight)
