class_name VelocitySprite extends Sprite2D

@export var moving:bool = true

var acceleration:Vector2 = Vector2.ZERO
var velocity:Vector2 = Vector2.ZERO

func _process(elapsed:float) -> void:
	if not moving: return
	
	# copying haxeflixel formulas cuz fuck your mother in the ass :3333
	var velocity_delta:Vector2 = _get_velocity_delta(velocity, acceleration, elapsed)
	
	position.x += (velocity.x + velocity_delta.x) * elapsed
	position.y += (velocity.y + velocity_delta.y) * elapsed
	
	velocity.x += velocity_delta.x * 2.0
	velocity.y += velocity_delta.y * 2.0

static func _compute_velocity(velocity:float, acceleration:float, elapsed:float) -> float:
	return velocity + (acceleration * elapsed if acceleration != 0.0 else 0.0)

static func _get_velocity_delta(velocity:Vector2, acceleration:Vector2, elapsed:float) -> Vector2:
	return Vector2(
		0.5 * (_compute_velocity(velocity.x, acceleration.x, elapsed) - velocity.x),
		0.5 * (_compute_velocity(velocity.y, acceleration.y, elapsed) - velocity.y),
	)
