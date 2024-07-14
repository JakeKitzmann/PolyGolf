extends Control

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene



func _on_play_pressed():
	pass


func _on_options_pressed():
	get_tree().change_scene_to_file('res://options_menu.tscn')

func _on_quit_pressed():
	get_tree().quit() 

func _on_host_game_pressed():
	peer.create_server(1027)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$CanvasLayer.hide()
	
func _on_join_game_pressed():
	peer.create_client('127.0.0.1', 1027)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()

	
func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred('add_child', player)
	
func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)
	
func del_player(id):
	rpc('_del_player', id)
	
@rpc('any_peer', "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
