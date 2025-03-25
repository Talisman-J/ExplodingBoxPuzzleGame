class_name Goal
extends Node2D
static var totalCount = 0
static var finalTotalCount = 0
func _init() -> void:
	totalCount += 1
	print(totalCount)
	
	
func _ready() -> void:
	finalTotalCount = totalCount
	$"../Camera2D/RichTextLabel".text = str(totalCount) + "/" + str(finalTotalCount)



func _on_goal_area_area_entered(area: Area2D) -> void:
	if area.name == "PlayerArea":
		totalCount -= 1
		$GoalArea/GoalColl.set_deferred("disabled", true)
		$GoalArea.visible = false
		$"../Camera2D/RichTextLabel".text = str(totalCount) + "/" + str(finalTotalCount)
