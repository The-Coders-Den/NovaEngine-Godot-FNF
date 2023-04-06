extends Sprite2D
class_name VelocitySprite

@export var moving:bool = true

var acceleration:Vector2 = Vector2.ZERO
var velocity:Vector2 = Vector2.ZERO

static func _process_sprite(sprite:VelocitySprite, elapsed:float) -> void:
	if sprite.moving:
		# copying haxeflixel formulas cuz fuck your mother in the ass :3333
		var velocity_delta:Vector2 = _get_velocity_delta(sprite.velocity, sprite.acceleration, \
				elapsed)
		
		sprite.position.x += (sprite.velocity.x + velocity_delta.x) * elapsed
		sprite.position.y += (sprite.velocity.y + velocity_delta.y) * elapsed
		
		sprite.velocity.x += velocity_delta.x * 2.0
		sprite.velocity.y += velocity_delta.y * 2.0

static func _compute_velocity(velocity:float, acceleration:float, elapsed:float) -> float:
	return velocity + (acceleration * elapsed if acceleration != 0.0 else 0.0)

static func _get_velocity_delta(velocity:Vector2, acceleration:Vector2, elapsed:float) -> Vector2:
	return Vector2(
		0.5 * (_compute_velocity(velocity.x, acceleration.x, elapsed) - velocity.x),
		0.5 * (_compute_velocity(velocity.y, acceleration.y, elapsed) - velocity.y),
	)
