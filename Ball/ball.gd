extends RigidBody3D

signal at_ball

const SPEED = 5.0

var move_to_player
@export var player: CharacterBody3D
@export var HUD: CanvasLayer
var launch = false

@onready var collision_shape = $CollisionShape3D

var physics_material = PhysicsMaterial.new()

# constructor
func _ready():
	print(physics_material.bounce) # make ball bouncy
	physics_material.bounce = .5
	physics_material_override = physics_material
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	if move_to_player:
		
		linear_velocity = Vector3.ZERO
		
		var target = player.position
		target.y += 1
		

		position = position.move_toward(target, delta * 20)
		var difference = position - player.position
		if difference.length() < 2:
			move_to_player = 0
	
	if position.y < 0:
		#position.y += 5
		pass

	if launch:
		point(global_transform.origin)

func _on_area_3d_body_entered(body):
	if body.to_string().begins_with('1'):
		emit_signal("at_ball")


func _input(event):
	if event is InputEventKey and event.is_action_pressed('return_ball') and not event.is_echo():
		move_to_player = 1
		
func point(pos: Vector3, radius = 0.05, color = Color.WHITE_SMOKE, persist_ms = 10):
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = sphere_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = pos

	sphere_mesh.radius = radius
	sphere_mesh.height = radius*2
	sphere_mesh.material = material

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	return await final_cleanup(mesh_instance, persist_ms)
	
func final_cleanup(mesh_instance: MeshInstance3D, persist_ms: float):
	get_tree().get_root().add_child(mesh_instance)
	if persist_ms == 1:
		await get_tree().physics_frame
		mesh_instance.queue_free()
	elif persist_ms > 0:
		await get_tree().create_timer(persist_ms).timeout
		mesh_instance.queue_free()
	else:
		return mesh_instance
	
func _on_player_draw_arc():
	launch = true
	await get_tree().create_timer(10).timeout
	launch = false
	
	await get_tree().create_timer(20).timeout
	
	
