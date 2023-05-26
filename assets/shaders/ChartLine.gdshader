shader_type canvas_item;

uniform vec4 bg_color = vec4(0.16, 0.13, 0.19, 1.0);

void fragment() {
	COLOR = bg_color;
	
	float pixel_size_y = 1.0 / 680.0;
	
	if (mod(UV.y, 0.25) <= pixel_size_y * 3.0)
		COLOR *= 3.5;
	else if (mod(UV.y, 1.0 / 16.0) <= pixel_size_y)
		COLOR *= 2.5;
}





