extends Control

signal shoot_button_pressed
signal slider_value_changed
signal item_list_selected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_shoot_button_pressed():
	emit_signal('shoot_button_pressed')


func _on_power_slider_value_changed(value):
	emit_signal('slider_value_changed', value)


func _on_item_list_item_selected(index):
	emit_signal('item_list_selected', index)


