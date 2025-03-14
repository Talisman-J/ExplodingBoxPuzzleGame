extends Node2D

#func _ready():
	#print("Hello World")
	#$Label.text = "Hello World"
#
#func _input(event):
	#if event.is_action_pressed("undo"):
		#$Label.modulate = Color.GREEN
	#if event.is_action_released("undo"):
		#$Label.modulate = Color.RED
	# Undo should work by saving coords in x, y list. Looping through list backwards one each time z is pressed. The issue is this only works for the player. (Vector2)
	
