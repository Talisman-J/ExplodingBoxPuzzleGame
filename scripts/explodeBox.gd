class_name ExplodeBox
extends CharacterBody2D

#var currPos = Vector2(0, 0)
var currPos = position
var input_vector = Vector2.ZERO
var moving = false # To lock movement until reaching tile
var didMove = false
var hasMoved = false
var exploded = false
var moves: Array = [] #Holds the position and the MOVECOUNT the box was moved on. 
var initPos = position


var MOVECOUNT : int = 0


@onready var player = get_node("/root/Main/Player")
@onready var ray = $RayCast2D

# Size of tile (adjust as needed)
const TILE_SIZE = 16

func _ready():
	player.moveCountChange.connect(_on_moveCountChange)
	initExplosionTimer()
	
func _on_moveCountChange(newMoveCount):
	if newMoveCount < MOVECOUNT:
		# Check undo for if position is there.
		check_undo()
		MOVECOUNT = newMoveCount
		if hasMoved:
			updateExplosionTimer(1)
	else:
		# Update for undo to be able to keep track of which move box was moved on. 
		MOVECOUNT = newMoveCount
		if hasMoved:
			updateExplosionTimer(-1)
	
	
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
	hasMoved = true
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

#HOW TO CHANGE THIS: Right click on the exploding box scene, turn on editable-children. 
@export var countdown : int = 5
@onready var tempCountdown = countdown
var firstMove = true
func updateExplosionTimer(num):
	# Timer variable decrements for each increment in MOVECOUNT. Increments for each decrement in MOVECOUNT. 
	# When reaches 0, explode. Will replay exploding animation when undoing.
	# When negative returns to 1, replace the exploding box.
	var textDisplay = $Label
	var prevCountdown = tempCountdown
	tempCountdown += num
	if exploded == true:
		if tempCountdown >= 0:
			#TODO: There's something wrong with my undo in here and I can't figure out what it is.
			# To replicate, get exploded. undo. get exploded again. Undo doesn't work. 
			#print("TEMP COUNTDOWN IS:", tempCountdown)
			if tempCountdown == 1 and firstMove == true:
				print("THIS IS TRUE ACTUALLY")
				await self.finishedVisualExplosion
			self.visible = true
			print("VISIBLE IS TRUEEEEEEEEEEEEE")
			if tempCountdown >= 1:
				#self.visible = true
				print("DOES THIS EVER RUNNNNNNNNN??????")
				$CollisionShape2D.disabled = false
				exploded = false
				$Fire.visible = false
				firstMove = true
		firstMove = false
	elif tempCountdown >= countdown:
		tempCountdown = countdown
		hasMoved = false
	textDisplay.text = str(tempCountdown)
	if prevCountdown > 0 and tempCountdown == 0:
		explode()

func initExplosionTimer():
	# Inputs the proper value into the exploding box.
	var textDisplay = $Label
	textDisplay.text = str(countdown)


#var alreadyDidInc = false    #UNUSED!!!!
#func tryIncreaseMoveCount():
	#if alreadyDidInc == false:
		#player.incrementMoveCount()
		#alreadyDidInc = true
signal finishedVisualExplosion() #finishedVis
func explode():
	#Change the name of this method to something else so that exploding boxes can blow up each other. 
	if !exploded:
		$Fire.visible = true
		#TODO: In the future for visual effect, hold this fire and an exploding barrel for a frame until player advances next turn for visual pleasantness.
		var temporaryMoveCount = MOVECOUNT
		#await player.moveCountChange
		#await get_tree().create_timer(.05).timeout
		#self.visible = false
		exploded = true
		$CollisionShape2D.disabled = true
		var expRad = $ExplosionRadius
		var angleDir
		for input in inputs:
			expRad.clear_exceptions()
			expRad.force_raycast_update()
			angleDir = inputs[input].angle()
			expRad.rotation = angleDir + PI/2
			expRad.force_raycast_update()
			
			var hitObjects = []
			var directions = []
			for i in range(2): # limit attempts to prevent infinite loop
				expRad.force_raycast_update()
				if expRad.is_colliding():
					var obj = expRad.get_collider()
					hitObjects.append(obj)
					
					expRad.add_exception(obj) # avoid hitting it again
				else:
					break
			for object in hitObjects:
				object.explode(input) #Make sure this is implemented in every object. Might want to add direction param
		await player.moveCountChange
		self.visible = false
		print("VISIBLE IS FALSEEEEEEEEEEE")
		finishedVisualExplosion.emit()
		
		#Explode when undone while still visible makes the box invisible. 
		
		#Explosion is not visible when undoing. 
		
		
		
		
		
		
	#Likely places to error: In the case that 2 objects are in 1 raycast
	#Intended behaviour: Push back one first, then closest second. 
	#Object exploded should be pushed back 2, whether they are on first or second tile exploded. This means different distance can be reached with corpse.
	
	
	#Shoot out raycast in 4 directions 32 px. Detect collisions with non walls. Break breakable walls. Kill player. Push playercorpse and boxes. 
	
	#set_cell
	
#	Kill player
#	Check if corpse can move.
#	If can:
		#Move corpse away from explosion one.
		#Check if it can move again:
			#If so move back again
			#Save position of corpse in undo function. Only increment moves by one.
		#If not:
			#Save position of corpse in undo function. Only increment moves by one. 
	
	#This will require an exploding state for the box and the player. Uses raycast similar to just normal checks. If player, pushes. If not stops. If box, pushes. If not stops. 
	#Have edge case for box hitting player into wall breaking wall killing player. Doesn't kill normally, just pushes. 
	#When enemies show up many more edge cases. Player hit by enemy dies. 
#	
	
