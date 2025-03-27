class_name PushBox
extends CharacterBody2D


var currPos = position
var resetPos = position
var input_vector = Vector2.ZERO
var moving = false # To lock movement until reaching tile
var didMove = false
var moves: Array = [] #Holds the position and the MOVECOUNT the box was moved on. 
var initPos = position
var gettingPushed = false
var undoing = false

var exploding = false

var MOVECOUNT : int = 0

var worked = false

@onready var ray = $RayCast2D

# Size of tile (adjust as needed)
const TILE_SIZE = 16
@onready var player = get_node("/root/Main/Player")
func _ready():
	player.moveCountChange.connect(_on_moveCountChange)
	
	
func _on_moveCountChange(newMoveCount):
	if newMoveCount <= MOVECOUNT:
		# Check undo for if position is there.
		
		#TODO: Undo is off by one. Should make it so that increments by one in the movement function
		# Decrement by one in the undo function.
		while MOVECOUNT > newMoveCount:
			check_undo()
	else:
		# Update for undo to be able to keep track of which move box was moved on. 
		MOVECOUNT = newMoveCount
	
func push_box(direction) -> bool:
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
	
	if !ray.is_colliding():
		return true
	else:
		var collidedNode = ray.get_collider()
		if collidedNode.name == "pushableBox" or (collidedNode.name == "explodingBox") or collidedNode.name == "Player":
			if exploding:
				if collidedNode.push_other(checkPos):
					return true
			else:
				if (collidedNode.name == "Player" or collidedNode.name == "pushableBox" or collidedNode.name == "explodingBox") and undoing: 
					# Allows the box to move back to its original position if undoing.
					# Otherwise, it collides with the player as the box tries to undo before the player undoes.
					return true
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
				moves.pop_back()
		if MOVECOUNT > 0:
			MOVECOUNT -= 1
	undoing = false

func explode(dir):
	exploding = true
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
	
func resetLevel():
	print("BOX RESET LEVEL IS CALLED")
	position = resetPos
	currPos = resetPos
	moves = []
	MOVECOUNT = 0
