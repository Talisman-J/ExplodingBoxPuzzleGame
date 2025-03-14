class_name PushBox
extends CharacterBody2D

#var currPos = Vector2(0, 0)
var currPos = position
var input_vector = Vector2.ZERO
var moving = false # To lock movement until reaching tile
var didMove = false
var moves: Array = [] #Holds the position and the MOVECOUNT the box was moved on. 
var initPos = position

var MOVECOUNT : int = 0



@onready var ray = $RayCast2D

# Size of tile (adjust as needed)
const TILE_SIZE = 16

func _ready():
	var player = get_node("/root/Main/Player")
	player.moveCountChange.connect(_on_moveCountChange)
	
func _on_moveCountChange(newMoveCount):
	if newMoveCount < MOVECOUNT:
		# Check undo for if position is there.
		check_undo()
		MOVECOUNT = newMoveCount
	else:
		# Update for undo to be able to keep track of which move box was moved on. 
		MOVECOUNT = newMoveCount
	
	
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
		didMove = false #shitty code
		
	var target_pos = currPos + input_vector * TILE_SIZE
	# You could add collision checks here if needed (e.g., walls)
	if can_move_to(direction):
		currPos = target_pos
		moving = true # Lock until move completes
		didMove = true
		moves.append([position, MOVECOUNT])
	position = currPos
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
	if moves.size() > 0:
		var currListItem = moves.get(moves.size() - 1)
		if (MOVECOUNT - 1) == currListItem.get(1):
			moves.pop_back()
			currPos = currListItem.get(0)
			self.position += (currPos - position)
	if moves.size() == 0:
		currPos = initPos
		self.position = initPos
