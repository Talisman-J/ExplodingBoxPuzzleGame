class_name ExplodeWall
extends CharacterBody2D


#var currPos = Vector2(0, 0)
var currPos = position
var resetPos = position
var exploded = false
var movedOn : int = -1 #Holds the position and the MOVECOUNT the box was moved on. 



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
	#print("explodedOn: ", movedOn, " + MOVECOUNT: ", MOVECOUNT)
	if (movedOn - 1) == MOVECOUNT:
		self.visible = true
		exploded = false
		$CollisionShape2D.disabled = false
		movedOn = -1
	

func explode(_dir):
	if !exploded:
		self.visible = false
		exploded = true
		$CollisionShape2D.disabled = true
		movedOn = MOVECOUNT
		print("Wall exploded!")



func _unhandled_input(event):
	if event.is_action_pressed("ResetLevel"):
		# "r"
		resetLevel()
		
func resetLevel():
	position = resetPos
	currPos = resetPos
	MOVECOUNT = 0
	
	self.visible = true
	exploded = false
	$CollisionShape2D.disabled = false
	
	movedOn = -1
