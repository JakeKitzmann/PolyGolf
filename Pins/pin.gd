extends Node3D

signal in_pin
signal pin_location

@export var player : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group('pins')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	print(body.to_string())
	if body.to_string().begins_with('Ball'):
		emit_signal('in_pin')
		
func set_player(id):
	player = id
	emit_signal('pin_location', global_position)
