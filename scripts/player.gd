extends CharacterBody2D

@onready var animation_tree = get_node("AnimationTree")

var currPos = Vector2(0, 0)
var input_vector = Vector2.DOWN
var moving : bool = false # To lock movement until reaching tile
var moves: Array = [] # Holds the move name and Movecount
static var MOVECOUNT : int = 0
var exploding = false
var gettingPushed = false
var dead : bool = false
var didMove = false
var turnsSinceDeath


var undoing = false


#TODO: Make explosions that go off at the same time all affect the player/boxes.
#TODO: Make it so that the player can still press movement keys to advance turns but just can't move. 

#TODO: If two enemies or an enemy and player run into box at same time, explode it. Have a little message that says "Turns out these boxes have gunpowder in them too." 

#
#func setMovingTrue():
	#moving = true
#func setMovingFalse():
	#moving = false

signal moveCountChange(newMoveCount)

func incrementMoveCount():
	MOVECOUNT += 1
	moveCountChange.emit(MOVECOUNT)
	print("New Movecount is: ", MOVECOUNT)

@onready var ray = $RayCast2D

# Size of tile (adjust as needed)
const TILE_SIZE = 16

func _unhandled_input(event):
	#if dead:
		#print("DEAD")
		#if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
			#MOVECOUNT += 1
			#moveCountChange.emit(MOVECOUNT)
			#turnsSinceDeath += 1
			#moves.append([position, input_vector])
		#if event.is_action_pressed("undoMove"):
			#undo()
			#turnsSinceDeath -= 1
			#if turnsSinceDeath == -1:
				#dead = false
		#return
	#if moving == false:
		# Only react to key presses (no continuous movement)
	if event.is_action_pressed("ui_right"):
		input_vector = Vector2(1, 0)
		moveRight()
	elif event.is_action_pressed("ui_left"):
		input_vector = Vector2(-1, 0)
		moveLeft()
	elif event.is_action_pressed("ui_up"):
		input_vector = Vector2(0, -1)
		moveUp()
	elif event.is_action_pressed("ui_down"):
		input_vector = Vector2(0, 1)
		moveDown()
	elif event.is_action_pressed("undoMove"):
		print("Tried to undo")
		undo()
	update_animation_parameters()

#In case box explodes into player
func push_other(direction) -> bool:
	if moving:
		return didMove # Prevent new movement until done with current one
	gettingPushed = true
	# Only react to key presses (no continuous movement)
	if direction == "right":
		input_vector = Vector2(1, 0)
		#attempt_move("right")
		moveRight()
	elif direction == "left":
		input_vector = Vector2(-1, 0)
		#attempt_move("left")
		moveLeft()
	elif direction == "up":
		input_vector = Vector2(0, -1)
		#attempt_move("up")
		moveUp()
	elif direction == "down":
		input_vector = Vector2(0, 1)
		#attempt_move("down")
		moveDown()
	gettingPushed = false
	#moves.pop_back()
	#moves.append([position, input_vector])
	print(didMove)
	return didMove

var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN}

func moveUp():
	var targPos = currPos + inputs["up"] * TILE_SIZE
	if can_move_to("up"):
		currPos = targPos
		position = currPos
		if !undoing and !gettingPushed and !exploding:
			MOVECOUNT += 1
			moveCountChange.emit(MOVECOUNT)
			moves.append(["MoveUp", MOVECOUNT])
		if undoing:
			MOVECOUNT -= 1
			moveCountChange.emit(MOVECOUNT)
		if gettingPushed:
			moves.pop_back()
			moves.append(["PushUp", MOVECOUNT])
			
			
	else:
		MOVECOUNT += 1
		moveCountChange.emit(MOVECOUNT)
		moves.append(["Inaction", MOVECOUNT])
	update_animation_parameters()
	
func moveDown():
	var targPos = currPos + inputs["down"] * TILE_SIZE
	if can_move_to("down"):
		currPos = targPos
		position = currPos
		if !undoing and !gettingPushed and !exploding:
			MOVECOUNT += 1
			moveCountChange.emit(MOVECOUNT)
			moves.append(["MoveDown", MOVECOUNT])
		if undoing:
			MOVECOUNT -= 1
			moveCountChange.emit(MOVECOUNT)
		if gettingPushed:
			moves.pop_back()
			moves.append(["PushDown", MOVECOUNT])
	else:
		MOVECOUNT += 1
		moveCountChange.emit(MOVECOUNT)
		moves.append(["Inaction", MOVECOUNT])
	update_animation_parameters()
	
func moveLeft():
	var targPos = currPos + inputs["left"] * TILE_SIZE
	if can_move_to("left"):
		currPos = targPos
		position = currPos
		if !undoing and !gettingPushed and !exploding:
			MOVECOUNT += 1
			moveCountChange.emit(MOVECOUNT)
			moves.append(["MoveLeft", MOVECOUNT])
		if undoing:
			MOVECOUNT -= 1
			moveCountChange.emit(MOVECOUNT)
		if gettingPushed:
			moves.pop_back()
			moves.append(["PushLeft", MOVECOUNT])
	else:
		MOVECOUNT += 1
		moveCountChange.emit(MOVECOUNT)
		moves.append(["Inaction", MOVECOUNT])
	update_animation_parameters()
	
func moveRight():
	var targPos = currPos + inputs["right"] * TILE_SIZE
	if can_move_to("right"):
		currPos = targPos
		position = currPos
		if !undoing and !gettingPushed and !exploding:
			MOVECOUNT += 1
			moveCountChange.emit(MOVECOUNT)
			moves.append(["MoveRight", MOVECOUNT])
		if undoing:
			MOVECOUNT -= 1
			moveCountChange.emit(MOVECOUNT)
		if gettingPushed:
			moves.pop_back()
			moves.append(["PushRight", MOVECOUNT])
	else:
		MOVECOUNT += 1
		moveCountChange.emit(MOVECOUNT)
		moves.append(["Inaction", MOVECOUNT])
	update_animation_parameters()

func moveAuto(dir):
	if(dir == "up"):
		moveUp()
	if(dir == "down"):
		moveDown()
	if(dir == "left"):
		moveLeft()
	if(dir == "right"):
		moveRight()





#func attempt_move(direction):
	#if exploding:
		#input_vector = inputs[direction]
	#var target_pos = currPos + input_vector * TILE_SIZE
	#
	#if can_move_to(direction):
		#currPos = target_pos
		##setMovingTrue() 
		#position = currPos
	#if gettingPushed == false and exploding == false:
		#moves.append([position, input_vector])
		#MOVECOUNT += 1
		#moveCountChange.emit(MOVECOUNT)
		#if dead == true:
			#turnsSinceDeath += 1
	#update_animation_parameters()
	#if !exploding:
		#setMovingFalse()

func update_animation_parameters():
	# Update blend position (for direction)
	animation_tree["parameters/Idle/blend_position"] = input_vector
	animation_tree["parameters/Walk/blend_position"] = input_vector
	
	# Switch between idle and walk based on whether input exists
	#if input_vector == Vector2.ZERO:
	animation_tree["parameters/playback"].travel("Idle")
	#else:
		#animation_tree["parameters/playback"].travel("Walk")
	
func can_move_to(checkPos) -> bool:
	var angleDir = inputs[checkPos].angle()
	ray.rotation = angleDir + PI/2
	ray.force_raycast_update()
	
	if !ray.is_colliding():
		print("Should be able to move")
		return true
	else:
		var collidedNode = ray.get_collider()
		if collidedNode.name == "pushableBox" or collidedNode.name == "explodingBox":
			if collidedNode.push_box(checkPos):
				print("Should be able to move X2")
				return true
		return false
		
		
#func undo():
	#if moves.size() > 1:
		##Pop the back and set player position to the new back. 
		#moves.pop_back()
		#var currListItem = moves.get(moves.size() - 1)
		#currPos = currListItem.get(0)
		#input_vector = currListItem.get(1)
		#MOVECOUNT -= 1
		#moveCountChange.emit(MOVECOUNT)
		#self.position += (currPos - position)
	#elif moves.size() == 1:
		## In the case of only one move being taken, doesn't try to go out of bounds. 
		#self.position += (- position)
		#currPos = position
		#moves.pop_back()
		## Resets input_vector. For some reason When game first starts, player is facing upwards instead of like this.
		#input_vector = Vector2.ZERO
		#MOVECOUNT -= 1
		#moveCountChange.emit(MOVECOUNT)
		
		
func undo():
	undoing = true
	if moves.size() > 0:
		var action = moves.get(moves.size() - 1).get(0)
		#MOVEMENT UNDO
		if action == "MoveUp":
			input_vector = Vector2(0, -1)
			moveDown()
		if action == "MoveDown":
			input_vector = Vector2(0, 1)
			moveUp()
		if action == "MoveRight":
			input_vector = Vector2(1, 0)
			moveLeft()
		if action == "MoveLeft":
			input_vector = Vector2(-1, 0)
			moveRight()
			
		#PUSHED UNDO -figured I would keep it seperate in case I want special behaviour. 
		if action == "PushUp":
			input_vector = Vector2(0, -1)
			moveDown()
		if action == "PushDown":
			input_vector = Vector2(0, 1)
			moveUp()
		if action == "PushRight":
			input_vector = Vector2(1, 0)
			moveLeft()
		if action == "PushLeft":
			input_vector = Vector2(-1, 0)
			moveRight()
		
		#EXPLODED UNDO
		if action == "Explode":
			if moves.get(moves.size() - 1).get(3) == "up":
				input_vector = Vector2(0, -1)
				print(moves.get(moves.size() - 1).get(2))
				for i in range(moves.get(moves.size() - 1).get(2)): #Gets the distance player travelled while exploding. 
					moveDown()
			if moves.get(moves.size() - 1).get(3) == "down":
				input_vector = Vector2(0, 1)
				print(moves.get(moves.size() - 1).get(2))
				for i in range(moves.get(moves.size() - 1).get(2)): #Gets the distance player travelled while exploding. 
					moveUp()
			if moves.get(moves.size() - 1).get(3) == "right":
				input_vector = Vector2(1, 0)
				print(moves.get(moves.size() - 1).get(2))
				for i in range(moves.get(moves.size() - 1).get(2)): #Gets the distance player travelled while exploding. 
					moveLeft()
			if moves.get(moves.size() - 1).get(3) == "left":
				input_vector = Vector2(-1, 0)
				print(moves.get(moves.size() - 1).get(2))
				for i in range(moves.get(moves.size() - 1).get(2)): #Gets the distance player travelled while exploding. 
					moveRight()
		#if action == "Explodedown":
			#input_vector = Vector2(0, 1)
			#print(moves.get(moves.size() - 1).get(2))
			#for i in range(moves.get(moves.size() - 1).get(2)): #Gets the distance player travelled while exploding. 
				#moveUp()
		#if action == "Exploderight":
			#input_vector = Vector2(1, 0)
			#print(moves.get(moves.size() - 1).get(2))
			#for i in range(moves.get(moves.size() - 1).get(2)): #Gets the distance player travelled while exploding. 
				#moveLeft()
		#if action == "Explodeleft":
			#input_vector = Vector2(-1, 0)
			#print(moves.get(moves.size() - 1).get(2))
			#for i in range(moves.get(moves.size() - 1).get(2)): #Gets the distance player travelled while exploding. 
				#moveRight()
			
		#NO ACTION
		if action == "Inaction":
			#Only decrements the MOVECOUNT
			MOVECOUNT -= 1
			moveCountChange.emit(MOVECOUNT)
		moves.pop_back()
		
	undoing = false
func explode(dir):
	exploding = true
	dead = true
	#print("EXPLODING PLAYER IN DIRECTION:", dir)
	#
	##This might error or might not be necessary
	#moves.pop_back()
	moves.append(["Inactive", MOVECOUNT])
	#
	##TODO: Now might be a good time to implement a new undo system since this one is so damn broken. 
	#
	var distance = 0
	if can_move_to(dir):
		moveAuto(dir)
		distance += 1
	if can_move_to(dir):
		moveAuto(dir)
		distance += 1
	print("Explode" + dir)
	print(distance)
	moves.append(["Explode", MOVECOUNT, distance, dir])
	#
	##IF TWO BOXES EXPLODES THIS OVERRIDES THE VALUE OF DEATH AND SO PLAYER GETS REVIVED AT SECOND BOX.
	#turnsSinceDeath = 0
	#
	#
	exploding = false
	
	
