extends Sprite2D
class_name WeekSprite

var target_y:int = 0
var flashing:bool = false

var since_last_flash:float = 0

func _process(delta):
	var lerp_val:float = clamp(delta * 60 * 0.17, 0, 1)
	position.y = lerp(position.y, ((target_y * 120.0) + 480.0 + texture.get_height() / 2), lerp_val)
	
	if flashing:
		since_last_flash += delta
		if since_last_flash >= 0.05:
			since_last_flash = 0
			modulate.r8 = 51 if modulate.r == 1.0 else 255
