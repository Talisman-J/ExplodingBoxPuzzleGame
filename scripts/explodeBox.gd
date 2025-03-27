class_name ExplodeBox
extends CharacterBody2D


var currPos = position
var resetPos = position
var input_vector = Vector2.ZERO
var moving = false # To lock movement until reaching tile
var didMove = false
var hasMoved = false
var exploded = false
var moves: Array = [] #Holds the position and the MOVECOUNT the box was moved on. 
var initPos = position
var exploding = false
var undoing = false
var gettingPushed = false


var MOVECOUNT : int = 0


@onready var player = get_node("/root/Main/Player")
@onready var ray = $RayCast2D

# Size of tile (adjust as needed)
const TILE_SIZE = 16

func _ready():
	player.moveCountChange.connect(_on_moveCountChange)
	initExplosionTimer()
	
var turnsSinceBlowUp = 0
	
func _on_moveCountChange(newMoveCount):
	if newMoveCount <= MOVECOUNT:
		if exploded:
			turnsSinceBlowUp -= 1
		# Check undo for if position is there.
		
		#TODO: Undo is off by one. Should make it so that increments by one in the movement function
		# Decrement by one in the undo function.
		while MOVECOUNT > newMoveCount:
			check_undo()
		if hasMoved:
			updateExplosionTimer(1)
	else:
		if exploded:
			turnsSinceBlowUp += 1
		# Update for undo to be able to keep track of which move box was moved on. 
		MOVECOUNT = newMoveCount
		if hasMoved:
			updateExplosionTimer(-1)

func checkMovement():
	print("The current box moves are: ", moves)
	if hasMoved:
		updateExplosionTimer(-1)
		moves.get(moves.size() - 1)[1] = moves.get(moves.size() - 1)[1] - 1
		print("The new box moves are: ", moves)
		

func push_box(direction) -> bool:
	print("hasMoved should be true here")
	hasMoved = true
	
	
	
	if moving:
		return didMove # Prevent new movement until done with current one
	if didMove == true:
		didMove = false
	
	# Only react to key presses (no continuous movement)
	if direction == "right":
		input_vector = Vector2(1, 0)
		if moveRight():
			moves.append(["MoveRight", MOVECOUNT])
			didMove = true
			print("MOVED TO THE RIGHT")
	elif direction == "left":
		input_vector = Vector2(-1, 0)
		if moveLeft():
			moves.append(["MoveLeft", MOVECOUNT])
			didMove = true
	elif direction == "up":
		input_vector = Vector2(0, -1)
		if moveUp():
			moves.append(["MoveUp", MOVECOUNT])
			didMove = true
	elif direction == "down":
		input_vector = Vector2(0, 1)
		if moveDown():
			moves.append(["MoveDown", MOVECOUNT])
			didMove = true
	else:
		didMove = false
	return didMove


func moveUp():
	moving = true
	var targPos = currPos + inputs["up"] * TILE_SIZE
	if can_move_to("up"):
		currPos = targPos
		position = currPos
		moving = false
		return true
	else:
		moving = false
		return false


func moveDown():
	moving = true
	var targPos = currPos + inputs["down"] * TILE_SIZE
	if can_move_to("down"):
		currPos = targPos
		position = currPos
		moving = false
		return true
	else:
		moving = false
		return false
	
	
func moveLeft():
	moving = true
	var targPos = currPos + inputs["left"] * TILE_SIZE
	if can_move_to("left"):
		currPos = targPos
		position = currPos
		moving = false
		return true
	else:
		moving = false
		return false

	
func moveRight():
	moving = true
	var targPos = currPos + inputs["right"] * TILE_SIZE
	if can_move_to("right"):
		currPos = targPos
		position = currPos
		moving = false
		return true
	else:
		moving = false
		return false


func moveAuto(dir):
	if(dir == "up"):
		moveUp()
	if(dir == "down"):
		moveDown()
	if(dir == "left"):
		moveLeft()
	if(dir == "right"):
		moveRight()


var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN}


func can_move_to(checkPos) -> bool:
	var angleDir = inputs[checkPos].angle()
	ray.rotation = angleDir + PI/2
	ray.force_raycast_update()
	
	if undoing:
		return true
	
	if !ray.is_colliding():
		return true
	else:
		var collidedNode = ray.get_collider()
		if collidedNode.name == "pushableBox" or (collidedNode.name == "explodingBox") or collidedNode.name == "Player":
			if exploding:
				if collidedNode.push_other(checkPos):
					return true
			else:
				#if (collidedNode.name == "Player" or collidedNode.name == "pushableBox" or collidedNode.name == "explodingBox") and undoing: 
					## Allows the box to move back to its original position if undoing.
					## Otherwise, it collides with the player as the box tries to undo before the player undoes.
					#return true
				if collidedNode.name == "Player": 
					return false
				else:
					if collidedNode.push_box(checkPos):
						return true
		return false

func getListActions(num):
	var actions = []
	for move in moves:
		if move.get(1) == (num - 1):
			if move.get(0) == "Explode":
				# So when undoing explosion logic is handled first before any movment/inaction/pushing logic. Prevents weirdness.
				actions.insert(0, move) 
			else:
				actions.append(move)
	return actions


var notUndoneOnExplosion = true

func check_undo():
	var actions = getListActions(MOVECOUNT)
	if actions.is_empty():
		if MOVECOUNT > 0:
			MOVECOUNT -= 1
		return
	else:
		undoing = true
		for action in actions:
			if moves.size() > 0:
				# Get each action for current MOVECOUNT. Loop through them. Will avoid the weird jank especially when not having an "Inactive" signal. 
				# Also means multiple events can happen at once.
				#Undo Explosion
				if action[0] == "Explode":
					if action[3] == "up":
						input_vector = Vector2(0, -1)
						print(action[2])
						for i in range(action[2]): # Gets the distance box travelled while exploding. 
							moveDown()
						
						
					if action[3] == "down":
						input_vector = Vector2(0, 1)
						print(action[2])
						for i in range(action[2]): # Gets the distance box travelled while exploding. 
							moveUp()
						
						
					if action[3] == "right":
						input_vector = Vector2(1, 0)
						print(action[2])
						for i in range(action[2]): # Gets the distance box travelled while exploding. 
							moveLeft()
						
						
					if action[3] == "left":
						input_vector = Vector2(-1, 0)
						print(action[2])
						for i in range(action[2]): # Gets the distance box travelled while exploding. 
							moveRight()
						
		
				#MOVEMENT UNDO
				if action[0] == "MoveUp":
					input_vector = Vector2(0, -1)
					moveDown()
					
				if action[0] == "MoveDown":
					input_vector = Vector2(0, 1)
					moveUp()
					
				if action[0] == "MoveRight":
					input_vector = Vector2(1, 0)
					moveLeft()
					
				if action[0] == "MoveLeft":
					input_vector = Vector2(-1, 0)
					moveRight()
					
				#PUSHED UNDO 
				if action[0] == "PushUp":
					input_vector = Vector2(0, -1)
					moveDown()
				if action[0] == "PushDown":
					input_vector = Vector2(0, 1)
					moveUp()
				if action[0] == "PushRight":
					input_vector = Vector2(1, 0)
					moveLeft()
				if action[0] == "PushLeft":
					input_vector = Vector2(-1, 0)
					moveRight()
					
				if action[0] == "BlowUp":
					if turnsSinceBlowUp == 0:
						print("SET THE THING TO FALSE")
						notUndoneOnExplosion = false
					
					
					
					print("BLOW UP WAS CALLED IN UNDO")
					self.visible = true
					$CollisionShape2D.disabled = false
					exploded = false
					$Fire.visible = false
					firstMove = true
					
					var plate = $ExplodeBoxArea.get_overlapping_areas()
					if plate.size() > 0:
						plate[0].area_entered.emit($ExplodeBoxArea)
					#firstMove = false
					
					
				moves.pop_back()
		if MOVECOUNT > 0:
			MOVECOUNT -= 1
	undoing = false

func explode(dir):
	print("THIS SHOULD EXPLODE")
	exploding = true
	hasMoved = true
	var distance = 0
	if can_move_to(dir):
		moveAuto(dir)
		distance += 1
	if can_move_to(dir):
		moveAuto(dir)
		distance += 1
	moves.append(["Explode", MOVECOUNT - 1, distance, dir])
	
	exploding = false


func push_other(direction) -> bool:
	if moving:
		return didMove # Prevent new movement until done with current one
	gettingPushed = true #Likely not necessary. Have this in case I need it later. 
	if direction == "right":
		input_vector = Vector2(1, 0)
		moveRight()
		moves.append(["PushRight", MOVECOUNT - 1])
	elif direction == "left":
		input_vector = Vector2(-1, 0)
		moveLeft()
		moves.append(["PushLeft", MOVECOUNT - 1])
	elif direction == "up":
		input_vector = Vector2(0, -1)
		moveUp()
		moves.append(["PushUp", MOVECOUNT - 1])
	elif direction == "down":
		input_vector = Vector2(0, 1)
		moveDown()
		moves.append(["PushDown", MOVECOUNT - 1])
	gettingPushed = false
	return didMove







#HOW TO CHANGE THIS: Right click on the exploding box scene, turn on editable-children. 
@export var countdown : int = 5
@onready var tempCountdown = countdown
@onready var resetCountdown = countdown
@onready var textDisplay = $Label
var firstMove = true

func updateExplosionTimer(num):
	# Timer variable decrements for each increment in MOVECOUNT. Increments for each decrement in MOVECOUNT. 
	# When reaches 0, explode. Will replay exploding animation when undoing.
	# When negative returns to 1, replace the exploding box.
	var prevCountdown = tempCountdown
	tempCountdown += num
	
	# HANDLES THE VISUAL ASPECTS
	if tempCountdown < 0:
		self.visible = false
	if tempCountdown == 0:
		self.visible = true
		$Fire.visible = true
	if tempCountdown > 0:
		$Fire.visible = false
		
	# HANDLES WHETHER BOX SHOULD BLOWUP OR NOT
	if tempCountdown >= countdown:
		tempCountdown = countdown
		hasMoved = false
	textDisplay.text = str(tempCountdown)
	if prevCountdown > 0 and tempCountdown == 0:
		blowUp()

func initExplosionTimer():
	# Inputs the proper value into the exploding box.
	var textDisplay = $Label
	textDisplay.text = str(countdown)


signal finishedVisualExplosion() #finishedVis
func blowUp(): # Horrible naming scheme to have explode and blowUp in the same object but this handles the explosion logic while explode handles logic for being exploded. 
	
	#Change the name of this method to something else so that exploding boxes can blow up each other. 
	if !exploded:
		moves.append(["BlowUp", MOVECOUNT - 1])
		
		#If the box is sitting on a pressure plate when it explodes, should exit the pressure plate area. 
		var plate = $ExplodeBoxArea.get_overlapping_areas()
		if plate.size() > 0:
			print("THIS RAN")
			plate[0].area_exited.emit($ExplodeBoxArea)
		
		exploding = true
		$Fire.visible = true
		var temporaryMoveCount = MOVECOUNT
		await get_tree().create_timer(.05).timeout
		exploded = true
		$CollisionShape2D.disabled = true
		
		var upObjects = $Fire/FireUpArea.get_overlapping_areas()
		var downObjects = $Fire/FireDownArea.get_overlapping_areas()
		var leftObjects = $Fire/FireLeftArea.get_overlapping_areas()
		var rightObjects = $Fire/FireRightArea.get_overlapping_areas()
		
		
		for i in range(0, 2, 1):
			print("This printed")
			if upObjects.size() > i:
				upObjects[i].get_parent().explode("up")
			if downObjects.size() > i:
				downObjects[i].get_parent().explode("down")
			if rightObjects.size() > i:
				rightObjects[i].get_parent().explode("right")
			if leftObjects.size() > i:
				leftObjects[i].get_parent().explode("left")
		await player.moveCountChange #Errors when undoing. 
		exploding = false

func _on_fire_up_area_area_entered(area: Area2D) -> void:
	if exploding:
		area.get_parent().explode("up")

func _on_fire_down_area_area_entered(area: Area2D) -> void:
	if exploding:
		area.get_parent().explode("down")

func _on_fire_right_area_area_entered(area: Area2D) -> void:
	if exploding:
		area.get_parent().explode("right")

func _on_fire_left_area_area_entered(area: Area2D) -> void:
	if exploding:
		area.get_parent().explode("left")

func resetLevel():
	position = resetPos
	currPos = resetPos
	moves = []
	MOVECOUNT = 0
	
	countdown = resetCountdown
	tempCountdown = countdown
	
	hasMoved = false
	exploded = false
	
	await get_tree().create_timer(.01).timeout
	
	$Fire.visible = false
	self.visible = true
	$CollisionShape2D.disabled = false
	
	var textDisplay = $Label
	textDisplay.text = str(countdown)
