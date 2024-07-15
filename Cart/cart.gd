extends VehicleBody3D

@export var max_steer = 0.9
@export var engine_power = 300
@onready var camera = $Camera3D

func _physics_process(delta):
	steering = move_toward(steering, Input.get_axis("player_right", "player_left") * max_steer, delta * 10)
	engine_force = Input.get_axis("player_back", 'player_forward') * engine_power
	camera.current = false
