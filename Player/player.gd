extends CharacterBody3D

# node dependencies
@onready var player = $AnimationPlayer
@onready var iron = $Armature/Skeleton3D/BoneAttachment3D/Iron
@onready var ball = $Ball
@onready var ball_pointer = $BallPointer
@onready var win_ui = $PlayerUI/Win

@onready var user_interface = $UserInterface
@onready var item_list = $UserInterface/ItemList

@onready var power_slider = $UserInterface/PowerSlider


@onready var camera_target = $WalkingParent/WalkingTarget
@onready var camera_parent = $WalkingParent
@onready var walking_camera = $WalkingParent/WalkingTarget/WalkingCamera
@onready var shooting_pivot = $ShootingParent/ShootingPivot
@onready var shooting_camera = $ShootingParent/ShootingPivot/ShotCamera
@onready var shooting_parent = $ShootingParent

# physics constants
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var rotation_speed = 5.0
@export var sensitivity = 500

# hud variables
var mouse_visible = 0
@onready var vp_size = get_viewport().size / 2 

# camera stats
var camera_T = float()
var cam_speed = float()
var pan_mode = 0

# shooting variables
var move_to_ball = 0
var shooting_offset = .5
var swing_once = 0
@export var in_shooting_mode = 0
var power_modulation  = 0

# club list {active (bool for shot), animation, power, phi}
var clubs = {'driver': [0, 'IronSwing', 50, 20], 'iron' : [0, 'IronSwing', 30, 45], 'wedge' : [0, 'IronSwing', 20, 90], 'putter' : [0, 'IronSwing', 10, 5]}

# strokes on hole
signal strokes

var follow_ball = 0

var at_ball = false

# signals
signal draw_arc
signal hud_toggle
signal pin_location

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
	print(is_multiplayer_authority())


func _ready():
	if not is_multiplayer_authority(): return
	
	walking_camera.current = true
	
	item_list.visible = true
	item_list.select(0) # set driver to active initially
	clubs['driver'][0] = 1

	
func switch_cam():
	print('running')
	$ShootingParent/ShootingPivot/ShotCamera.current = true
	Input.warp_mouse(Vector2(vp_size.x, vp_size.y))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	item_list.visible = true
	in_shooting_mode = 1
	ball_pointer.visible = false
	shooting_pivot.global_transform.origin = ball.global_transform.origin
	
func camera_follow_ball():
	walking_camera.look_at(ball.global_position)

# gameplay loop
func _physics_process(delta):
	
	if not is_multiplayer_authority(): return
	
	if not shooting_camera.current == true:
		walking_camera.current = true
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		player.play('Jump')
		
	# ball pointer
	ball_pointer.look_at(ball.global_transform.origin)
	
	# camera
	camera_smooth_follow(delta)
	
	if follow_ball:
		camera_follow_ball()
	
	# if / elif to determine game state (shooting vs not shooting)
	if in_shooting_mode:
		
		if Input.is_action_just_pressed('leave_shooting_mode'):
			walking_camera.current = true
			in_shooting_mode = 0	
		if player.current_animation != 'IronSwing':
			player.play("IdleSwing") # change to idle swing
			iron.visible = true
			
			if (ball.position - position).length() < 3: # stop ball if its slightly moving
						if not swing_once:
							ball.linear_velocity = Vector3.ZERO
							
		
		# keeps player facing ball
		rotation.y = shooting_pivot.rotation.y + deg_to_rad(90)
		
		# movement around ball to aim
		var camera_vector = shooting_camera.global_transform.origin - shooting_pivot.global_transform.origin
		var angle_to_ball = atan2(camera_vector.z, camera_vector.x)
		position.x = shooting_pivot.global_transform.origin.x  + .9 * cos(angle_to_ball + deg_to_rad(90))
		position.z = shooting_pivot.global_transform.origin.z + .9 * sin(angle_to_ball + deg_to_rad(90))
		
		# for all the clubs check if the player is swinging that club
		# can be used later to adjust power and arc based on vals in 
		# club dictionary
		for club_type in clubs:
			var club = clubs[club_type]
			
			if club[0] == 1: # if the club is active
				if player.current_animation == club[1] and swing_once:  # swinging the club
					swing_once = 0

					# shot power modulation
					var power = club[2] * power_modulation
					power = power / 100
				
					# calculate shot angle opposite of camera
					var shot_angle = angle_to_ball + deg_to_rad(180) 
					
					# shot delayed by timers to match animation
					await get_tree().create_timer(.75).timeout
					shoot_ball.rpc(delta, shot_angle, deg_to_rad(club[3]), power)
					emit_signal('draw_arc') # tell ball to draw arc following shot
					await get_tree().create_timer(1.5).timeout
					
					ball_pointer.visible = true
					item_list.visible = true
					
					# switch to the normal camera and out of shooting mode
					walking_camera.current = true
					
					# camera follow ball
					var prev_camera_rotation = walking_camera.rotation
					follow_ball = 1
					await get_tree().create_timer(3).timeout
					follow_ball = 0
					
					# return to normal camera
					walking_camera.look_at(camera_target.global_position)
					walking_camera.rotation = prev_camera_rotation
					
					club[0] = 0
					in_shooting_mode = 0
					shooting_parent.aim_shot_toggle()
					rotate_y(deg_to_rad(90))
					camera_parent.rotate_y(deg_to_rad(90))
			
	elif not in_shooting_mode: # elif to keep from running immediately after shot
		
			
		if Input.is_action_just_pressed("enter_shooting_mode") and at_ball:
			switch_cam()
		
		# jump
		if Input.is_action_just_pressed("player_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		# movement vector (Vector2D)
		var input_vector = Input.get_vector("player_left", 'player_right', "player_forward", "player_back")

		# get direction from vector
		var direction = (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
		
		# if moving
		if direction:
			iron.visible = false
			
			# if not swinging
			if not swing_once and not player.current_animation == 'IronSwing':
				if is_on_floor() and not Input.is_action_pressed('player_run'):
					player.play.rpc("Walk")
				else:
					player.play('Run')
					direction = direction * 3 # increase magnitude of direction for faster movement
					
			# move character
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			
		# if not moving
		else:
			# stay still
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			
			
			if is_on_floor() and not player.current_animation == 'IronSwing':
				iron.visible = false
				player.play("Idle")
			
		# camera target rotation
		camera_T = camera_target.global_transform.basis.get_euler().y
		
		# rotate character w keys
		if direction != Vector3.ZERO:
			rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), SPEED * delta)
		
	move_and_slide() # apply movement
	
# move ball when shot - eventually convert to spherical
@rpc("call_local")
func shoot_ball(delta, theta, phi, power):

	# send an impulse of magnitude power in direction angle 
	var force = Vector3.ZERO
	force.x = power * cos(theta)
	force.z = power * sin(theta)
	force.y = power * sin(phi)
	
	ball.apply_central_impulse(force)
	
	emit_signal('strokes')
	
# user input
func _input(event):
	pass
	# leave shooting mode
	
		
# wacky zany goofy silly camera movement
func camera_smooth_follow(delta):
	var cam_offset = Vector3(0, 3, 3).rotated(Vector3.UP, camera_T)
	cam_speed = 20
	var cam_timer = clamp(delta * cam_speed / 20, 0, 1)
	camera_parent.global_transform.origin = camera_parent.global_transform.origin.lerp(self.global_transform.origin + cam_offset, cam_timer)

# recieve that ball went in signal from pin object
func _on_pin_in_pin():
	win_ui.visible = true


func _on_item_list_item_selected(index):
	
	# inactivate all clubs
	for club in clubs:
		clubs[club][0] = 0
		
	var list = $PlayerUI/ItemList
	var club = item_list.get_item_text(index)
	
	# activate selected club
	if club == 'Driver':
		clubs['driver'][0] = 1
	elif club == 'Iron':
		clubs['iron'][0] = 1
	elif club == 'Wedge':
		clubs['wedge'][0] = 1
	elif club == 'Putter':
		clubs['putter'][0] = 1
		
		

func _on_power_slider_value_changed(value):
	power_modulation = value

# swing 
func _on_swing_button_pressed():
	swing_once = 1
	iron.visible = true
	player.play("IronSwing")


func _on_pin_pin_location(location):
	emit_signal('pin_location', location)


func _on_ball_at_ball():
	print('at_ball')
	at_ball = true
	
