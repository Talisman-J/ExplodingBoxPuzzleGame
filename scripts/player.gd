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

func _unhandled_input(event):
	#print(MOVECOUNT, " THE MOVECOUNT IS CURRENTLY THIS!!!")
	if moving == true:
		return
	if pauseTime == true:
		return
	
	pauseTime = true
	
	
	if event.is_action_pressed("ui_right"):
		input_vector = Vector2(1, 0)
		#THIS ORDER IS IMPORTANT.
		#In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
		moves.append(["MoveRight", MOVECOUNT])
		moveRight()
		MOVECOUNT += 1
		moveCountChange.emit(MOVECOUNT)
		
	elif event.is_action_pressed("ui_left"):
		input_vector = Vector2(-1, 0)
		#THIS ORDER IS IMPORTANT.
		#In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
		moves.append(["MoveLeft", MOVECOUNT])
		moveLeft()
		MOVECOUNT += 1
		moveCountChange.emit(MOVECOUNT)
		
	elif event.is_action_pressed("ui_up"):
		input_vector = Vector2(0, -1)
		#THIS ORDER IS IMPORTANT.
		#In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
		moves.append(["MoveUp", MOVECOUNT])
		moveUp()
		MOVECOUNT += 1
		moveCountChange.emit(MOVECOUNT)
		
	elif event.is_action_pressed("ui_down"):
		input_vector = Vector2(0, 1)
		#THIS ORDER IS IMPORTANT.
		#In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
		moves.append(["MoveDown", MOVECOUNT])
		moveDown()
		MOVECOUNT += 1
		moveCountChange.emit(MOVECOUNT)
		
	elif event.is_action_pressed("undoMove"):
		#print("Tried to undo")
		if MOVECOUNT > 0:
			undo()
			
	elif event.is_action_pressed("PrintSolutionMap"):
		# "p"
		printMovesSoFar()
	elif event.is_action_pressed("RunCustomSolution"):
		# "u"
		runCustomSolution()
		
	update_animation_parameters()

	await get_tree().create_timer(.05).timeout
	pauseTime = false
	
	
	
var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN}



func moveUp():
	moving = true
	var targPos = currPos + inputs["up"] * TILE_SIZE
	if can_move_to("up"):
		currPos = targPos
		position = currPos
	else:
		moves.pop_back() #Gets rid of the movement appending and replaces it with inaction
		moves.append(["Inaction", MOVECOUNT])
	#update_animation_parameters()
	moving = false
	
func moveDown():
	moving = true
	var targPos = currPos + inputs["down"] * TILE_SIZE
	if can_move_to("down"):
		currPos = targPos
		position = currPos
	else:
		moves.pop_back() #Gets rid of the movement appending and replaces it with inaction
		moves.append(["Inaction", MOVECOUNT])
	#update_animation_parameters()
	moving = false
	
func moveLeft():
	moving = true
	var targPos = currPos + inputs["left"] * TILE_SIZE
	if can_move_to("left"):
		currPos = targPos
		position = currPos
	else:
		moves.pop_back() #Gets rid of the movement appending and replaces it with inaction
		moves.append(["Inaction", MOVECOUNT])
	#update_animation_parameters()
	moving = false
	
func moveRight():
	moving = true
	var targPos = currPos + inputs["right"] * TILE_SIZE
	if can_move_to("right"):
		currPos = targPos
		position = currPos
	else:
		moves.pop_back() #Gets rid of the movement appending and replaces it with inaction
		moves.append(["Inaction", MOVECOUNT])
	#update_animation_parameters()
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
		#print("Should be able to move")
		return true
	else:
		var collidedNode = ray.get_collider()
		print(collidedNode.name)
		if collidedNode.name == "pushableBox" or collidedNode.name == "explodingBox":
			if collidedNode.push_box(checkPos):
				#print("Should be able to move X2")
				return true
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
						
					if action[3] == "down":
						input_vector = Vector2(0, 1)
						#print(action[2])
						for i in range(action[2]): # Gets the distance player travelled while exploding. 
							moveUp()
						exploded = false
						
					if action[3] == "right":
						input_vector = Vector2(1, 0)
						#print(action[2])
						for i in range(action[2]): # Gets the distance player travelled while exploding. 
							moveLeft()
						exploded = false
						
					if action[3] == "left":
						input_vector = Vector2(-1, 0)
						#print(action[2])
						for i in range(action[2]): # Gets the distance player travelled while exploding. 
							moveRight()
						exploded = false
		
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
					
				# NO ACTION
				if action[0] == "Inaction":
					#Does nothing. If I want to change the logic later can change this. 
					pass
				
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
	
	
	
func printMovesSoFar():
	var fullListOfMoves = ""
	for move in moves:
		fullListOfMoves += str(move) + ","
	print(fullListOfMoves)
	
func runCustomSolution():
	var customSolution1 = [["MoveUp", 0],["MoveUp", 1],["MoveUp", 2],["MoveDown", 3],["MoveDown", 4],["MoveUp", 5],["MoveUp", 6],["MoveUp", 7],["MoveLeft", 8],["MoveLeft", 9],["MoveDown", 10],["MoveDown", 11],["MoveDown", 12],["MoveDown", 13],["MoveDown", 14],["MoveDown", 15],["MoveLeft", 16],["MoveLeft", 17],["MoveLeft", 18],["MoveLeft", 19],["MoveUp", 20],["MoveUp", 21],["MoveUp", 22],["MoveLeft", 23],["MoveUp", 24],["MoveLeft", 25],["MoveLeft", 26],["MoveDown", 27],["MoveRight", 28],["MoveRight", 29],["MoveUp", 30],["MoveDown", 31],["MoveRight", 32],["MoveRight", 33],["MoveRight", 34],["MoveRight", 35],["MoveLeft", 36],["MoveLeft", 37],["MoveLeft", 38],["MoveLeft", 39],["MoveUp", 40],["MoveLeft", 41],["MoveUp", 42],["MoveUp", 43],["MoveUp", 44],["MoveRight", 45],["MoveRight", 46],["MoveDown", 47],["MoveDown", 48],["MoveDown", 49],["MoveLeft", 50],["MoveDown", 51],["MoveRight", 52],["MoveRight", 53],["MoveRight", 54],["MoveRight", 55],["MoveRight", 56],["MoveRight", 57],["MoveLeft", 58],["MoveLeft", 59],["MoveLeft", 60],["MoveLeft", 61],["MoveLeft", 62],["MoveLeft", 63],["MoveLeft", 64],["MoveLeft", 65],["MoveLeft", 66],["MoveUp", 67],["MoveUp", 68],["MoveUp", 69],["MoveRight", 70],["MoveUp", 71],["MoveRight", 72],["MoveDown", 73],["MoveDown", 74],["MoveDown", 75],["MoveLeft", 76],["MoveDown", 77],["MoveRight", 78],["MoveRight", 79],["MoveRight", 80],["MoveRight", 81],["MoveRight", 82],["MoveRight", 83],["MoveRight", 84],["MoveRight", 85],["MoveRight", 86],["MoveRight", 87],["MoveRight", 88],["MoveRight", 89],["MoveDown", 90],["MoveRight", 91],["MoveUp", 92],["MoveUp", 93],["MoveUp", 94],["MoveDown", 95],["MoveDown", 96],["MoveLeft", 97]]
	var customSolution2 = [["MoveUp", 0],["MoveUp", 1],["MoveUp", 2],["MoveDown", 3],["MoveDown", 4],["MoveUp", 5],["MoveUp", 6],["MoveUp", 7],["MoveLeft", 8],["MoveLeft", 9],["MoveDown", 10],["MoveDown", 11],["MoveDown", 12],["MoveLeft", 13],["MoveRight", 14],["MoveUp", 15],["MoveDown", 16],["MoveLeft", 17],["MoveLeft", 18],["MoveLeft", 19],["MoveLeft", 20],["MoveLeft", 21],["MoveUp", 22],["MoveUp", 23],["MoveLeft", 24],["MoveLeft", 25],["MoveDown", 26],["MoveRight", 27],["MoveRight", 28],["MoveUp", 29],["MoveLeft", 30],["MoveUp", 31],["MoveUp", 32],["MoveUp", 33],["MoveRight", 34],["MoveRight", 35],["MoveDown", 36],["MoveDown", 37],["MoveDown", 38],["MoveDown", 39],["MoveDown", 40],["MoveDown", 41],["MoveUp", 42],["MoveUp", 43],["MoveLeft", 44],["MoveLeft", 45],["MoveLeft", 46],["MoveLeft", 47],["MoveUp", 48],["MoveUp", 49],["MoveUp", 50],["MoveRight", 51],["MoveUp", 52],["MoveRight", 53],["MoveDown", 54],["MoveDown", 55],["MoveDown", 56],["MoveDown", 57],["MoveDown", 58],["MoveDown", 59],["MoveUp", 60],["MoveUp", 61],["MoveLeft", 62],["MoveLeft", 63],["MoveDown", 64],["MoveDown", 65],["MoveDown", 66],["MoveRight", 67],["MoveRight", 68],["MoveRight", 69],["MoveRight", 70],["MoveRight", 71],["MoveRight", 72],["MoveRight", 73],["MoveLeft", 74],["MoveLeft", 75],["MoveLeft", 76],["MoveRight", 77],["MoveRight", 78],["MoveRight", 79],["MoveRight", 80],["MoveDown", 81],["MoveDown", 82],["MoveDown", 83],["MoveRight", 84],["MoveRight", 85],["MoveRight", 86],["MoveRight", 87],["MoveRight", 88],["MoveRight", 89],["MoveUp", 90],["MoveUp", 91],["MoveLeft", 92],["MoveRight", 93],["MoveUp", 94],["MoveRight", 95],["MoveRight", 96],["MoveRight", 97],["MoveLeft", 98],["MoveLeft", 99],["MoveLeft", 100],["MoveDown", 101],["MoveDown", 102],["MoveRight", 103],["MoveRight", 104],["MoveRight", 105],["MoveRight", 106],["MoveUp", 107],["MoveUp", 108],["MoveUp", 109],["MoveUp", 110],["MoveRight", 111],["MoveUp", 112],["MoveLeft", 113]]
	for solut in customSolution1: #CHANGE THIS TO RUN DIFF SOLUTIONS
		await get_tree().create_timer(.05).timeout
		if solut.get(0) == "MoveRight":
			input_vector = Vector2(1, 0)
			#THIS ORDER IS IMPORTANT.
			#In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
			moves.append(["MoveRight", MOVECOUNT])
			moveRight()
			MOVECOUNT += 1
			moveCountChange.emit(MOVECOUNT)
			
		elif solut.get(0) == "MoveLeft":
			input_vector = Vector2(-1, 0)
			#THIS ORDER IS IMPORTANT.
			#In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
			moves.append(["MoveLeft", MOVECOUNT])
			moveLeft()
			MOVECOUNT += 1
			moveCountChange.emit(MOVECOUNT)
			
		elif solut.get(0) == "MoveUp":
			input_vector = Vector2(0, -1)
			#THIS ORDER IS IMPORTANT.
			#In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
			moves.append(["MoveUp", MOVECOUNT])
			moveUp()
			MOVECOUNT += 1
			moveCountChange.emit(MOVECOUNT)
			
		elif solut.get(0) == "MoveDown":
			input_vector = Vector2(0, 1)
			#THIS ORDER IS IMPORTANT.
			#In the case of an Inaction move being recorded, it pops the movement from the list and replaces it. This always has to be appened before movement. 
			moves.append(["MoveDown", MOVECOUNT])
			moveDown()
			MOVECOUNT += 1
			moveCountChange.emit(MOVECOUNT)
	
	
