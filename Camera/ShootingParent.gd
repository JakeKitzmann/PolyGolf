extends Node3D

@export var camera_target : Node3D
@export var pitch_max = 50
@export var pitch_min = 20
var yaw = float()
var pitch = float()
var yaw_sensitivity = .0005
var pitch_sensitivity = .0005

@onready var vp_size = get_viewport().size / 2 

var aiming = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event):
	if event.is_action_pressed('aim_shot'):
		aim_shot_toggle()

		
	if event is InputEventMouseMotion and Input.get_mouse_mode() != 0 and aiming == 1:
		camera_target.rotation.y -= event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity
		
func _physics_process(delta):
	camera_target.rotation.x= lerpf(camera_target.rotation.x, pitch, delta * 10)
	
	pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	
func aim_shot_toggle():
		if aiming == 1:
			Input.warp_mouse(Vector2(vp_size.x, vp_size.y))
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			aiming = 0
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			aiming = 1
