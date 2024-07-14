extends CanvasLayer

var hud_show = 0

@export var player: CharacterBody3D
@export var ball: RigidBody3D
 
signal switch_cam

func _ready():
	$DevUI.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var difference = player.position - ball.position 

	if difference.length() < 3:
		hud_show = 1
	else:
		hud_show = 0
			
	shooting_toggle(hud_show)

	
func shooting_toggle(toggle):
	if toggle == 1:
		$DevUI.show()
	else:
		$DevUI.show()


