extends Node

@onready var MainMenu = $CanvasLayer/MainMenu
@onready var AddressEntry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var postfx = $CanvasLayer/PostFX
@export var spawn_location : Node3D

const Player = preload("res://Player/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('quit'):
		get_tree().quit()


func _on_host_button_pressed() -> void:
	MainMenu.hide()
	postfx.visible = true
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()


func _on_join_button_pressed() -> void:
	MainMenu.hide()
	postfx.visible = true
	
	enet_peer.create_client(AddressEntry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	position_player.rpc(player.name)

@rpc("call_local")
func position_player(player_name):
	var player = get_node("/root/World/%s" % player_name)
	player.spawn_point = spawn_location.position
	player.position = spawn_location.position

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discovered Failed Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
	
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
