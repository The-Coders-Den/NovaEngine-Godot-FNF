shader_type canvas_item;

uniform vec4 swag_color : source_color;

void fragment() {
	vec4 old = COLOR;
	COLOR = vec4(swag_color.r, swag_color.g, swag_color.b, old.a);
}
