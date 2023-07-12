shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,filter_linear;
uniform float multiplier : hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	vec3 new_col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float avg_color = (COLOR.r + COLOR.g + COLOR.b) * 0.3333333333333;
	new_col = mix(COLOR.rgb, vec3(avg_color), multiplier);
	
	COLOR.rgb = new_col;
}
