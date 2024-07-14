extends Label

@onready var player = $Player

var strokes = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var output = 'Strokes: '
	output += str(strokes)
	text = output


func _on_player_strokes():
	strokes += 1
	return strokes
