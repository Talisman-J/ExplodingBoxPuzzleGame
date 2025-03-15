class_name ExplodeWall
extends CharacterBody2D


#var currPos = Vector2(0, 0)
var currPos = position
var exploded = false
var movedOn : int = -1 #Holds the position and the MOVECOUNT the box was moved on. 
var initPos = position


var MOVECOUNT : int = 0


# Size of tile (adjust as needed)
const TILE_SIZE = 16

func _ready():
	var player = get_node("/root/Main/Player")
	player.moveCountChange.connect(_on_moveCountChange)
	
func _on_moveCountChange(newMoveCount):
	if newMoveCount < MOVECOUNT:
		# Check undo for if position is there.
		MOVECOUNT = newMoveCount
		undoExplode()
		
		
	else:
		# Update for undo to be able to keep track of which move box was moved on. 
		MOVECOUNT = newMoveCount
		

func undoExplode():
	print("movedOn: ", movedOn, " + MOVECOUNT: ", MOVECOUNT)
	if movedOn == MOVECOUNT:
		self.visible = true
		exploded = false
		$CollisionShape2D.disabled = false
		movedOn = -1
	

func explode():
	if !exploded:
		self.visible = false
		exploded = true
		$CollisionShape2D.disabled = true
		movedOn = MOVECOUNT
		print("Wall exploded!")
	
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
	pass
