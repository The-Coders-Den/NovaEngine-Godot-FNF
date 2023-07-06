shader_type canvas_item;

uniform float frequency = 8.0;
uniform float amplitude = 0.05;

uniform vec3 color : source_color;
uniform sampler2D SCREEN_TEX : hint_screen_texture,filter_linear;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec2 texCoord = SCREEN_UV;
    
	vec2 pulse = sin(TIME - frequency * texCoord);
	float dist = 2.0 * length(texCoord.y - 0.5);

	vec2 newCoord = texCoord + amplitude * vec2(pulse.y, pulse.x * 0.5); // y-axis only; 
	
	vec2 interpCoord = mix(newCoord, texCoord, dist);
	
	COLOR = texture(SCREEN_TEX, interpCoord);
	COLOR.rgb *= color;
}
