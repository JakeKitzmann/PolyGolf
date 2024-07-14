extends ColorRect

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var play_button: Button = find_child('Resume')
@onready var quit_button: Button = find_child('Quit')
@onready var is_paused = 0

func _ready():
	pass

func unpause():
	is_paused = 0
	animator.play('Unpause')
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func pause():
	is_paused = 1
	animator.play('Pause')
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func paused():
	return is_paused

func _on_resume_pressed():
	unpause()
func _on_quit_pressed():
	get_tree().quit()
