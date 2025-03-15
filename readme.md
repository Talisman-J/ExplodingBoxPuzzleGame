**TODO:**

1. Make Undo. 

   1. Go back one player POS [X]

   2. Go back one of everything player interacted with.  [X]

   3. If player runs into wall, should still move forward a turn and be able to be undoed. [X]

2. Make exploding boxes 

   1. Kill Player when in radius []

   2. Explode after a certain amount of tiles are moved by the player. Number is on box, counts down each turn passed by player.  []

   3. Push player corpse/enemy corpse/boxes back 2 tiles []

   4. Boxes push player when exploded. Stop when hit wall. If Push player into wall, break wall, kill player.  []

   5. Break open certain walls when exploded in their radius. []

   6. Enemy when diving away from explosion can break walls. Dies. []

   7. Enemys when exploded into wall dont break it. []

   8. Have a version that can be triggered multiple times but can't move. (So enemy can trigger over and over to create fire obstacle only corpses pushed by enemy can pass through.) []

   9. Maybe have different levels. (Green 1 block, Red 2 block, Purple 3 block explosion) []

3. Make Enemies (goat with fire horns)

   1. Walks along a patrol route in a loop. Kills player if touching. Pushes corpse if not against wall. Breaks wall with corpse if it is against the wall and pushes corpse into broken slot to continue uninterrupted in its route. Would be nice to have a custom animation of winding up a charge. []

   2. If fuse lit, pushes until two tiles on fuse left. Uses one tile to go wide-eyed. Next dives right of whatever direction it was facing if possible. If not dives left. If both blocked, dives right. []

   3. If hits wall, breaks wall and dies. []

   4. Lights fuse if touches block. []

   5. Can push player into revive block. Eyes go wide with surprise taking a turn. []

   6. Can be revived by revive block. []

   7. If exploded, launches 2 blocks. Acts like box in that if pushes player into wall, breaks wall and kills player. Difference is it kills player no matter what while pushing them. []

4. Make Revive block in floor

   1. Revives corpses. []

   2. Can stand on it to "survive" an explosion as long as explosion doesn't knock you off. []

   3. Ambiguous symbol so it can be put in starter rooms without the player knowing what they are/what they are used for. Bonus points for hiding them under boxes so they look like just where boxes spawn. Then player can come back w/ new knowledge of what they do. []

5. Move camera between rooms []
	1. Empty undo queue. 
	2. Initialize Objects in new room.
	3. Decide whether to reset room when leaving or keep it. 

6. Maybe make a decent level editor for easier building and integrated custom level support in the future. []

7. Add minimap. []

8. UI []

9. Save game data. []

10.  Create a reset for just a single room Monster's Expedition style. []

11.  Objective is to break every wall that you are "Supposed to" meaning the ones that can be blown up. The ones that require weird tricks like getting blown into them, the unbreakable walls basically, do not count towards the total. Have a broken wall counter in top right. When resetting rooms, does not reset broken wall, does reset the unbreakable broken walls. This means that certain elements can be reused for different walls. []
