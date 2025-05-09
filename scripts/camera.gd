extends Camera2D
#Moves the camera up
func _on_area_up_area_entered(area: Area2D) -> void:
	if area.name == "PlayerArea":
		var newPos = Vector2(0, -208)
		position = position + newPos

#Moves the camera down
func _on_area_down_area_entered(area: Area2D) -> void:
	if area.name == "PlayerArea":
		var newPos = Vector2(0, 208)
		position = position + newPos

#Moves the camera right
func _on_area_right_area_entered(area: Area2D) -> void:
	if area.name == "PlayerArea":
		var newPos = Vector2(432, 0)
		position = position + newPos

#Moves the camera left
func _on_area_left_area_entered(area: Area2D) -> void:
	if area.name == "PlayerArea":
		var newPos = Vector2(-432, 0)
		position = position + newPos
