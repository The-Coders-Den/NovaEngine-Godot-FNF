extends Sprite2D
class_name VelocitySprite

@export var moving:bool = true

var completedMovement:bool = false

var acceleration:Vector2 = Vector2(0, 0)
var velocity:Vector2 = Vector2(0, 0)
var velocityDelta:float = 0.0
var maxVelocity:Vector2 = Vector2(INF, INF)
	
func _process(elapsed: float) -> void:
	if moving:
		# copying haxeflixel formulas cuz fuck your mother in the ass :3333
		
		velocityDelta = 0.5 * (computeVelocity(velocity.x, acceleration.x, 0, maxVelocity.x, elapsed) - velocity.x)
		velocity.x += velocityDelta
		var delta = velocity.x * elapsed
		velocity.x += velocityDelta
		position.x += delta

		velocityDelta = 0.5 * (computeVelocity(velocity.y, acceleration.y, 0, maxVelocity.y, elapsed) - velocity.y)
		velocity.y += velocityDelta
		delta = velocity.y * elapsed
		velocity.y += velocityDelta
		position.y += delta

func computeVelocity(Velocity:float, Acceleration:float, Drag:float, Max:float, Elapsed:float) -> float:
	if Acceleration != 0:
		Velocity += Acceleration * Elapsed
	elif Drag != 0:
		var drag:float = Drag * Elapsed;
		
		if Velocity - drag > 0:
			Velocity -= drag
		elif Velocity + drag < 0:
			Velocity += drag
		else:
			Velocity = 0;
	if (Velocity != 0) && (Max != 0):
		if Velocity > Max:
			Velocity = Max
		elif Velocity < -Max:
			Velocity = -Max
	
	return Velocity
