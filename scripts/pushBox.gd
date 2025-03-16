class_name PushBox
extends CharacterBody2D

#var currPos = Vector2(0, 0)
var currPos = position
var input_vector = Vector2.ZERO
var moving = false # To lock movement until reaching tile
var didMove = false
var moves: Array = [] #Holds the position and the MOVECOUNT the box was moved on. 
var initPos = position

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
		MOVECOUNT = newMoveCount
		check_undo()
		print("Current Movecount is: ", MOVECOUNT)
	else:
		# Update for undo to be able to keep track of which move box was moved on. 
		MOVECOUNT = newMoveCount
		print("Current Movecount is: ", MOVECOUNT)
	
func push_box(direction) -> bool:
	if moving:
		return didMove # Prevent new movement until done with current one

	# Only react to key presses (no continuous movement)
	if direction == "right":
		input_vector = Vector2(1, 0)
		attempt_move("right")
	elif direction == "left":
		input_vector = Vector2(-1, 0)
		attempt_move("left")
	elif direction == "up":
		input_vector = Vector2(0, -1)
		attempt_move("up")
	elif direction == "down":
		input_vector = Vector2(0, 1)
		attempt_move("down")
	return didMove

func attempt_move(direction):
	if didMove == true:
		didMove = false # shitty code
		
	var target_pos = currPos + input_vector * TILE_SIZE
	if can_move_to(direction):
		currPos = target_pos
		moving = true # Lock until move completes
		didMove = true
		#if !exploding:
		print("This ran")
		moves.append([position, MOVECOUNT])
		#moves.append([position, MOVECOUNT])
		position = currPos
		worked = true
	else:
		worked = false
	moving = false 
	

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
		return false


#For undo keep track of a global moveCount variable.
#Whenever box is moved, add vector new pos and moveCount to 2D array
#For each time moveCount decrements (using signals), check if == to stored moveCount. 
#If so: pop_back and move box to new back (next newest move). 

#This way it stores only the necessary stuff and only calls it when necessary to hopefully be at least somewhat efficient. 

func check_undo():
	print("Size of moves is: ", moves.size())
	if moves.size() > 0:
		var currListItem = moves.get(moves.size() - 1)
		print("OUTSIDE the if statement: ",currListItem.get(1))
		if (MOVECOUNT) == currListItem.get(1):
			print("Inside the if statement: ",currListItem.get(1))
			moves.pop_back()
			currPos = currListItem.get(0)
			self.position += (currPos - position)
	if moves.size() == 0:
		currPos = initPos
		self.position = initPos


func explode(dir):
	exploding = true
	print(dir)
	if moves.size() <= 0:
		moves.append([position, MOVECOUNT - 1])
	if moves.size() > 0:
		var lastElement = moves[moves.size() - 1]
		if lastElement.get(1) != MOVECOUNT - 1:
			moves.append([position, MOVECOUNT - 1])
	
	print("Before explosion: ", MOVECOUNT - 1, " Movecount and ", position, " Position" )
	push_box(dir)
	if worked == true:
		moves.pop_back()
	push_box(dir)
	if worked == true:
		moves.pop_back()
	print(MOVECOUNT, " Movecount and ", position, " Position" )
	print("Box Blew UP")
	exploding = false
	
	#reference instance at countdown of 1 instead of 0. Return to 1 when countdown returns to 1
	
	#ISSUE HERE:
	#Saves the position of before explosion and after on the same turn. 
	#Have a prepare signal that sends warning at countdown of 1 and saves. 
