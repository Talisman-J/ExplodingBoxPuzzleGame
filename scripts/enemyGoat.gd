extends Node2D

@onready var animation_tree = get_node("AnimationTree")

@onready var currPos = position
var resetPos: Vector2 = position

var input_vector = Vector2.DOWN
var moving : bool = false # To lock movement until reaching tile
var moves: Array = [] # Holds the move name and Movecount
var MOVECOUNT : int = 0
var exploding = false
var gettingPushed = false
var dead : bool = false
var didMove = false
var turnsSinceDeath = 0

var canUndo = 0

var exploded = false
var undoing = false

var pauseTime = false






#TODO: Make explosions that go off at the same time all affect the player/boxes.
#TODO: Make it so that the player can still press movement keys to advance turns but just can't move. 

#TODO: If two enemies or an enemy and player run into box at same time, explode it. Have a little message that says "Turns out these boxes have gunpowder in them too..." 

#TODO: Fix the bug where undo pushes the box overriding the undid movement!!!!
# Maybe turn off collision of box while undoing??




signal moveCountChange(newMoveCount)


@onready var ray = $RayCast2D

# Size of tile (adjust as needed)
const TILE_SIZE = 16

var inputs = {
	"right": Vector2.RIGHT,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"up": Vector2.UP}
@export var moveDirection = "up"

@onready var player = get_node("/root/Main/Player")
func _ready():
	player.moveCountChange.connect(_on_moveCountChange)
	input_vector = inputs[moveDirection]
	update_animation_parameters()
	
	
func _on_moveCountChange(newMoveCount):
	if newMoveCount <= MOVECOUNT:
		# Check undo for if position is there.
		
		#TODO: Undo is off by one. Should make it so that increments by one in the movement function
		# Decrement by one in the undo function.
		while MOVECOUNT > newMoveCount:
			undo()
	else:
		# Update for undo to be able to keep track of which move box was moved on. 
		if !dead:
			moves.append(["Move" + str(moveDirection), MOVECOUNT, moveDirection])
			moveAuto(moveDirection)
		else:
			moves.append(["Inaction", MOVECOUNT, moveDirection])
		print(moves)
		MOVECOUNT = newMoveCount



#func _unhandled_input(event):
	##print(MOVECOUNT, " THE MOVECOUNT IS CURRENTLY THIS!!!")
	#if moving == true:
		#return
	#if pauseTime == true:
		#return
	#
	#pauseTime = true
	#
	#if event.is_action_pressed("ui_right"):
		#if dead:
			#moves.append(["Inaction", MOVECOUNT])
			#MOVECOUNT += 1
			#moveCountChange.emit(MOVECOUNT)
			#turnsSinceDeath += 1
		#else:
			#input_vector = Vector2(1, 0)
			##THIS ORDER IS IMPORTANT.
			##In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
			#moves.append(["MoveRight", MOVECOUNT])
			#moveRight()
			#MOVECOUNT += 1
			#moveCountChange.emit(MOVECOUNT)
		#
	#elif event.is_action_pressed("ui_left"):
		#if dead:
			#moves.append(["Inaction", MOVECOUNT])
			#MOVECOUNT += 1
			#moveCountChange.emit(MOVECOUNT)
			#turnsSinceDeath += 1
		#else:
			#input_vector = Vector2(-1, 0)
			##THIS ORDER IS IMPORTANT.
			##In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
			#moves.append(["MoveLeft", MOVECOUNT])
			#moveLeft()
			#MOVECOUNT += 1
			#moveCountChange.emit(MOVECOUNT)
		#
	#elif event.is_action_pressed("ui_up"):
		#if dead:
			#moves.append(["Inaction", MOVECOUNT])
			#MOVECOUNT += 1
			#moveCountChange.emit(MOVECOUNT)
			#turnsSinceDeath += 1
		#else:
			#input_vector = Vector2(0, -1)
			##THIS ORDER IS IMPORTANT.
			##In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
			#moves.append(["MoveUp", MOVECOUNT])
			#moveUp()
			#MOVECOUNT += 1
			#moveCountChange.emit(MOVECOUNT)
		#
	#elif event.is_action_pressed("ui_down"):
		#if dead:
			#moves.append(["Inaction", MOVECOUNT])
			#MOVECOUNT += 1
			#moveCountChange.emit(MOVECOUNT)
			#turnsSinceDeath += 1
		#else:
			#input_vector = Vector2(0, 1)
			##THIS ORDER IS IMPORTANT.
			##In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
			#moves.append(["MoveDown", MOVECOUNT])
			#moveDown()
			#MOVECOUNT += 1
			#moveCountChange.emit(MOVECOUNT)
		#
	#elif event.is_action_pressed("undoMove"):
		##print("Tried to undo")
		#if MOVECOUNT > 0:
			#undo()
	#elif event.is_action_pressed("ResetLevel"):
		## "r"
		#resetLevel()
		#
	#update_animation_parameters()
	#await get_tree().create_timer(.05).timeout
	#pauseTime = false


func moveUp():
	if !undoing:
		input_vector = Vector2(0, -1)
		update_animation_parameters()
	moving = true
	var targPos = currPos + inputs["up"] * TILE_SIZE
	if can_move_to("up"):
		print("TRYING TO MOVE UP")
		currPos = targPos
		position = currPos
	else:
		moves.pop_back() #Gets rid of the movement appending and replaces it with inaction
		moveDirection = "right"
		moves.append(["Inaction", MOVECOUNT, moveDirection])
		if !undoing:
			input_vector = Vector2(1, 0)
			update_animation_parameters()

	moving = false
	
func moveDown():
	if !undoing:
		input_vector = Vector2(0, 1)
		update_animation_parameters()
	moving = true
	var targPos = currPos + inputs["down"] * TILE_SIZE
	if can_move_to("down"):
		currPos = targPos
		position = currPos
		print("TRYING TO MOVE DOWN")
	else:
		moves.pop_back() #Gets rid of the movement appending and replaces it with inaction
		moveDirection = "left"
		moves.append(["Inaction", MOVECOUNT, moveDirection])
		if !undoing:
			input_vector = Vector2(-1, 0)
			update_animation_parameters()
	moving = false
	
func moveLeft():
	if !undoing:
		input_vector = Vector2(-1, 0)
		update_animation_parameters()
	moving = true
	var targPos = currPos + inputs["left"] * TILE_SIZE
	if can_move_to("left"):
		currPos = targPos
		position = currPos
		print("TRYING TO MOVE LEFT")
	else:
		moves.pop_back() #Gets rid of the movement appending and replaces it with inaction
		moveDirection = "up"
		moves.append(["Inaction", MOVECOUNT, moveDirection])
		if !undoing:
			input_vector = Vector2(0, -1)
			update_animation_parameters()
	moving = false
	
func moveRight():
	if !undoing:
		input_vector = Vector2(1, 0)
		update_animation_parameters()
	moving = true
	var targPos = currPos + inputs["right"] * TILE_SIZE
	if can_move_to("right"):
		currPos = targPos
		position = currPos
		print("TRYING TO MOVE RIGHT")
	else:
		moves.pop_back() #Gets rid of the movement appending and replaces it with inaction
		moveDirection = "down"
		moves.append(["Inaction", MOVECOUNT, moveDirection])
		if !undoing:
			input_vector = Vector2(0, 1)
			update_animation_parameters()
	moving = false

func moveAuto(dir):
	if(dir == "up"):
		moveUp()
	if(dir == "down"):
		moveDown()
	if(dir == "left"):
		moveLeft()
	if(dir == "right"):
		moveRight()



func update_animation_parameters():
	# Update blend position (for direction)
	animation_tree["parameters/GoatIdle/blend_position"] = input_vector
	#animation_tree["parameters/Walk/blend_position"] = input_vector
	
	# Switch between idle and walk based on whether input exists
	#if input_vector == Vector2.ZERO:
	animation_tree["parameters/playback"].travel("GoatIdle")
	#else:
		#animation_tree["parameters/playback"].travel("Walk")
	

func can_move_to(checkPos) -> bool:
	var angleDir = inputs[checkPos].angle()
	ray.rotation = angleDir + PI/2
	ray.force_raycast_update()
	if undoing:
		return true
	
	if !ray.is_colliding():
		#print("Should be able to move")
		return true
	else:
		var collidedNode = ray.get_collider()
		print(collidedNode.name)
		if collidedNode.name == "pushableBox" or collidedNode.name == "explodingBox":
			if collidedNode.push_box(checkPos):
				print("Should be able to move X2")
				if collidedNode.name == "explodingBox":
					print("TRIED TO CHECK MOVEMENT")
					#collidedNode.checkMovement()
				return true
			#if collidedNode.name == "explodingBox":
				#collidedNode.checkMovement()
		return false
		
		
func getListActions(num):
	var actions = []
	for move in moves:
		if move.get(1) == num:
			if move.get(0) == "Explode":
				# So when undoing explosion logic is handled first before any movment/inaction/pushing logic. Prevents weirdness.
				actions.insert(0, move) 
			else:
				actions.append(move)
	return actions
	
func undo():
	MOVECOUNT -= 1
	moveCountChange.emit(MOVECOUNT)
	#print(MOVECOUNT)
	if turnsSinceDeath > 0:
		turnsSinceDeath -= 1
	print(turnsSinceDeath)
	var actions = getListActions(MOVECOUNT)
	if actions.is_empty():
		return
	else:
		for action in actions:
			undoing = true
			if moves.size() > 0:
				# Get each action for current MOVECOUNT. Loop through them. Will avoid the weird jank especially when not having an "Inactive" signal. 
				# Also means multiple events can happen at once.
				#print("ACTION is ", action, " AND MOVE COUNT IS ", MOVECOUNT)
				#Undo Explosion
				if action[0] == "Explode":
					if action[3] == "up":
						input_vector = Vector2(0, -1)
						#print(action[2])
						for i in range(action[2]): # Gets the distance player travelled while exploding. 
							moveDown()
						exploded = false
						if turnsSinceDeath == 0:
							dead = false #When exploded twice while dead this breaks...
						
					if action[3] == "down":
						input_vector = Vector2(0, 1)
						#print(action[2])
						for i in range(action[2]): # Gets the distance player travelled while exploding. 
							moveUp()
						exploded = false
						if turnsSinceDeath == 0:
							dead = false #When exploded twice while dead this breaks...
						
					if action[3] == "right":
						input_vector = Vector2(1, 0)
						#print(action[2])
						for i in range(action[2]): # Gets the distance player travelled while exploding. 
							moveLeft()
						exploded = false
						if turnsSinceDeath == 0:
							dead = false #When exploded twice while dead this breaks...
						
					if action[3] == "left":
						input_vector = Vector2(-1, 0)
						#print(action[2])
						for i in range(action[2]): # Gets the distance player travelled while exploding. 
							moveRight()
						exploded = false
						if turnsSinceDeath == 0:
							dead = false #When exploded twice while dead this breaks...
		
				#MOVEMENT UNDO
				if action[0] == "Moveup":
					#input_vector = Vector2(0, -1)
					input_vector = inputs[action[2]]
					moveDirection = action[2]
					moveDown()
					
				if action[0] == "Movedown":
					#input_vector = Vector2(0, 1)
					input_vector = inputs[action[2]]
					moveDirection = action[2]
					moveUp()
					
				if action[0] == "Moveright":
					#input_vector = Vector2(1, 0)
					input_vector = inputs[action[2]]
					moveDirection = action[2]
					moveLeft()
					
				if action[0] == "Moveleft":
					#input_vector = Vector2(-1, 0)
					input_vector = inputs[action[2]]
					moveDirection = action[2]
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
					
				# NO ACTION
				if action[0] == "Inaction":
					#Does nothing. If I want to change the logic later can change this. 
					input_vector = inputs[action[2]]
					
				update_animation_parameters()
				moves.pop_back()
		#MOVECOUNT -= 1
		#moveCountChange.emit(MOVECOUNT)
	undoing = false
	
	
	
func explode(dir):
	MOVECOUNT -= 1 #Because moving/inactivity increments move count each time, need to subtract so that explosion can take place on proper turn. 
	
	#print("EXPLODED ON MOVE: ", MOVECOUNT)
	exploding = true
	dead = true
	exploded = true

	
	var distance = 0
	if can_move_to(dir):
		moveAuto(dir)
		distance += 1
	if can_move_to(dir):
		moveAuto(dir)
		distance += 1
	#print("Explode" + dir)
	#print(distance)
	moves.append(["Explode", MOVECOUNT, distance, dir])
	
	# TODO: Make explode box have a continous check for things entering its radius on that movecount. This is so stuff can be chained. 
	
	exploding = false
	
	MOVECOUNT += 1



#In case box explodes into player
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
	
	
func resetLevel():
	position = resetPos
	currPos = resetPos
	moves = []
	dead = false
