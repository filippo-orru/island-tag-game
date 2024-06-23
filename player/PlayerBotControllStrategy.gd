class_name PlayerBotControllStrategy
extends PlayerControllStrategy

var targetPlayer: Player
var player: Player

const directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
var _rng = RandomNumberGenerator.new()
var lastDirection = Vector2i.ZERO

func get_target_vector(position: Vector2i) -> Vector2i:
	if not player.hunter:
		var hunterDirection: Vector2i = targetPlayer.targetPos - targetPlayer.fromPos
		
		if hunterDirection == Vector2i.ZERO or _rng.randi_range(0, 10) < 1:
			# When the hunter is not moving (or in ~10% of the moves) go in a random direction.
			# But prefere the last moving direction.
			var directionPickList = [lastDirection, lastDirection, lastDirection, lastDirection]
			directionPickList.append_array(directions)
			directionPickList.shuffle()
			
			lastDirection = directionPickList[0]
		elif (hunterDirection.x * player.fromPos.x) <= 0 and (hunterDirection.y * player.fromPos.y) <= 0:
			# Do not follow the hunter if he is running away from "me"
			lastDirection = hunterDirection * -1
		else:
			# Run away from the hunter if he is running in "my" direction
			lastDirection = hunterDirection
		
		return lastDirection
	else:
		var delta: Vector2i = (position / GameWorld.GRID_SIZE) - targetPlayer.fromPos
		if delta == Vector2i.ZERO:
			return delta
		elif (delta.x > delta.y and delta.x != 0) or delta.y == 0:
			if delta.x < 0:
				return Vector2i.RIGHT
			else:
				return Vector2i.LEFT
		else:
			if delta.y < 0:
				return Vector2i.DOWN
			else:
				return Vector2i.UP
