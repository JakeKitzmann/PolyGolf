extends Label

@export var stroke_counter : Label
@export var ball : RigidBody3D

var par = 3
var do_once = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if visible == true and do_once:
		do_once = 0
		
		ball.visible = false
		
		var strokes = stroke_counter.strokes
		
		if strokes == par - 2:
			text += 'Eagle!'
		elif strokes == par - 1:
			text += 'Birdie!'
		elif strokes == par:
			text += 'Par'
		elif strokes == par + 1:
			text += 'Bogey'
		elif strokes == par + 2:
			text += 'Double Bogey'
		else:
			var difference = strokes - par
			text += '+ difference'
