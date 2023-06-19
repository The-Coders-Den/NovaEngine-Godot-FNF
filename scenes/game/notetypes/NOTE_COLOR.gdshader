shader_type canvas_item;

uniform vec3 NOTE_COLOR: source_color = vec3(0.5,1,0.6);

void fragment() {
	if (COLOR.r > 0.8 && COLOR.b < 0.1)
		COLOR.rgb = NOTE_COLOR + UV.x * TEXTURE_PIXEL_SIZE.x;
	else if(COLOR.a > 0.0)
		COLOR.rgb = vec3(1.0,1.0,1.0);
}
