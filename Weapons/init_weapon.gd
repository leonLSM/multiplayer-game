@tool

extends Node3D

@export var WEAPON_TYPE : Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			load_weapon()

@onready var weapon_mesh : MeshInstance3D = $WeaponMesh

var equipped_weapons = ["res://Weapons/Assault Rifle/Assault Rifle.tres", 
"res://Weapons/Pistol/Pistol.tres"]
var weapon_slot = 0

func _ready() -> void:
	load_weapon()

func _unhandled_input(_event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_pressed("Select_Down"):
		switch_weapon.rpc(1)
		print(weapon_slot)
	elif Input.is_action_pressed("select_up"):
		switch_weapon.rpc(-1)
		print(weapon_slot)

func load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation = WEAPON_TYPE.rotation

@rpc("call_local")
func switch_weapon(number):
	if weapon_slot == equipped_weapons.size() - 1:
		weapon_slot = 0
	elif weapon_slot <= 0:
		weapon_slot = equipped_weapons.size() - 1
	else:
		weapon_slot += number
	WEAPON_TYPE = load(equipped_weapons[weapon_slot])
	load_weapon()
