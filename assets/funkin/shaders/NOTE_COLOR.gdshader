shader_type canvas_item;
uniform vec3 color : source_color;
uniform bool enabled;

void fragment() {
	vec4 finalColor = COLOR;
	
	if (enabled) {
		float diff = finalColor.r - ((finalColor.g + finalColor.b) / 2.0);
		COLOR.rgb = vec3(((finalColor.g + finalColor.b) / 2.0) + (color.r * diff), finalColor.g + (color.g * diff), finalColor.b + (color.b * diff));
	} 
	
	else {
		COLOR = finalColor;
	}
	
	}