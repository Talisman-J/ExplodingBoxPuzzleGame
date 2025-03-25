extends Node2D

func _on_plate_area_area_entered(area: Area2D) -> void:
	if area.name == "BoxArea":
		#$DoorArea.visible = false
		$DoorArea/ClosedDoorSprite.visible = false
		$DoorArea/DoorColl.set_deferred("disabled", true)
		

func _on_plate_area_area_exited(area: Area2D) -> void:
	if area.name == "BoxArea":
		#$DoorArea.visible = true
		$DoorArea/ClosedDoorSprite.visible = true
		$DoorArea/DoorColl.set_deferred("disabled", false)
