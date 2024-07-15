extends Node


var enet_peer = ENetMultiplayerPeer.new()
var local_player_character

var connected_peer_ids = []

@onready var menu = $MainMenu

const PORT = 9999
const ADDR = '127.0.0.1'

const Player = preload('res://Player/player.tscn')

func _on_play_pressed():
	pass

func _on_options_pressed():
	get_tree().change_scene_to_file('res://options_menu.tscn')

func _on_quit_pressed():
	get_tree().quit()

func _on_host_game_pressed():
	menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())
	
func _on_join_game_pressed():
	menu.hide()
	
	enet_peer.create_client('localhost', PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
