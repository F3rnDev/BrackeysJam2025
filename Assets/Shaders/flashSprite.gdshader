shader_type canvas_item;

uniform vec4 sourceColor:source_color = vec4(1.0);
uniform float hint:hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, sourceColor.rgb, hint);
	COLOR = color;
}