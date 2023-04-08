shader_type canvas_item;
uniform vec4 color : source_color;
uniform vec4 outlineColor : source_color;
void fragment() {
	if(color != outlineColor)
		COLOR = vec4(color.r,color.g,color.b,1.0);
}
