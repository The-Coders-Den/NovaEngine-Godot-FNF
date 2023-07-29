shader_type canvas_item;
uniform vec3 RED : source_color;
uniform vec3 GREEN : source_color;
uniform vec3 BLUE : source_color;
uniform bool enabled = true;
void fragment() {
	if(enabled)
		COLOR.rgb = (COLOR.r * RED + COLOR.g * GREEN + COLOR.b * BLUE);
}
