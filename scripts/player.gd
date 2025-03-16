extends CharacterBody2D

@onready var animation_tree = get_node("AnimationTree")

var currPos = Vector2(0, 0)
var input_vector = Vector2.ZERO
var moving : bool = false # To lock movement until reaching tile
var moves: Array = [] # Holds the location of each move and which direction the player was facing at the time. 
static var MOVECOUNT : int = 0
var exploding = false

func setMovingTrue():
	moving = true
func setMovingFalse():
	moving = false

signal moveCountChange(newMoveCount)

func incrementMoveCount():
	MOVECOUNT += 1
	moveCountChange.emit(MOVECOUNT)
	print("New Movecount is: ", MOVECOUNT)

@onready var ray = $RayCast2D

# Size of tile (adjust as needed)
const TILE_SIZE = 16

func _unhandled_input(event):
	if moving == false:
		# Only react to key presses (no continuous movement)
		if event.is_action_pressed("ui_right"):
			input_vector = Vector2(1, 0)
			attempt_move("right")
		elif event.is_action_pressed("ui_left"):
			input_vector = Vector2(-1, 0)
			attempt_move("left")
		elif event.is_action_pressed("ui_up"):
			input_vector = Vector2(0, -1)
			attempt_move("up")
		elif event.is_action_pressed("ui_down"):
			input_vector = Vector2(0, 1)
			attempt_move("down")
		elif event.is_action_pressed("undoMove"):
			undo()
		update_animation_parameters()

func attempt_move(direction):
	var target_pos = currPos + input_vector * TILE_SIZE
	
	if can_move_to(direction):
		currPos = target_pos
		setMovingTrue() # Lock until move completes
		position = currPos
	moves.append([position, input_vector])
	MOVECOUNT += 1
	moveCountChange.emit(MOVECOUNT)
	update_animation_parameters()
	if !exploding:
		setMovingFalse()

func update_animation_parameters():
	# Update blend position (for direction)
	animation_tree["parameters/Idle/blend_position"] = input_vector
	animation_tree["parameters/Walk/blend_position"] = input_vector
	
	# Switch between idle and walk based on whether input exists
	#if input_vector == Vector2.ZERO:
	animation_tree["parameters/playback"].travel("Idle")
	#else:
		#animation_tree["parameters/playback"].travel("Walk")

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
		if collidedNode.name == "pushableBox" or collidedNode.name == "explodingBox":
			if collidedNode.push_box(checkPos):
				return true
		return false
		
		
func undo():
	#TODO: Undo should reset each time a new room is entered so as not to build up way too much data. Set return point to where new room is entered
	
	#TODO: In order to handle wall breaks, create a new object where broken wall is that increments for each move. Decrements for each undo. When reaches 0, replace wall. 
	#Same can be done for exploding blocks and any other blocks that get removed. Corpses will be similar to boxes. 
	
	#TODO: Make other objects undo also. 
	# -Maybe just give each object a position array. Seems like it would get laggy quick though. 
	# -Different solution have marker points that do diff things so basically only has to know when and what happened but not where. 
	# Would get out of hand with how many things can happen though especially in all 4 direcions... 
	
	if moves.size() > 1:
		#Pop the back and set player position to the new back. 
		moves.pop_back()
		var currListItem = moves.get(moves.size() - 1)
		currPos = currListItem.get(0)
		input_vector = currListItem.get(1)
		MOVECOUNT -= 1
		moveCountChange.emit(MOVECOUNT)
		self.position += (currPos - position)
	elif moves.size() == 1:
		# In the case of only one move being taken, doesn't try to go out of bounds. 
		self.position += (- position)
		currPos = position
		moves.pop_back()
		# Resets input_vector. For some reason When game first starts, player is facing upwards instead of like this.
		input_vector = Vector2.ZERO
		MOVECOUNT -= 1
		moveCountChange.emit(MOVECOUNT)
		
func explode(dir):
	exploding = true
	print("Player Blew UP")
	setMovingTrue()
	
	
