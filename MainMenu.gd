extends Control


var multiplayer_peer = ENetMultiplayerPeer.new()
var local_player_character

var connected_peer_ids = []

const PORT = 9999
const ADDR = '127.0.0.1'

signal play_pressed
signal quit_pressed
signal host_pressed
signal join_pressed

func _on_play_pressed():
	emit_signal('play_pressed')

func _on_options_pressed():
	get_tree().change_scene_to_file('res://options_menu.tscn')

func _on_quit_pressed():
	emit_signal('quit_pressed')

func _on_host_game_pressed():
	emit_signal('host_pressed')
	
func _on_join_game_pressed():
	emit_signal('join_pressed')
