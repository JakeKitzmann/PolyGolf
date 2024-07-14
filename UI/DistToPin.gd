extends Label

@export var ball : RigidBody3D
@onready var pin_hole_one = Vector3(-109, 4,72 )


var difference_vector
var distance_to_pin
var pin_location

# Called when the node enters the scene tree for the first time.
func _ready():
	difference_vector = Vector3.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	difference_vector = ball.global_position - pin_hole_one
	distance_to_pin = int(difference_vector.length())
	text = 'Distance To Pin: '
	text += str(distance_to_pin)
