shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	vec3 bg = vec3(0.05098, 0.05098, 0.05882);
	vec3 gold = vec3(0.7843, 0.6627, 0.4314);
	vec3 warm = vec3(0.392, 0.314, 0.157);
	float top_glow = exp(-length((uv - vec2(0.5, 0.0)) * vec2(1.25, 2.2)) * 2.4) * 0.07;
	float bottom_left = exp(-length((uv - vec2(0.2, 1.0)) * vec2(1.6, 2.4)) * 2.0) * 0.06;
	float bottom_right = exp(-length((uv - vec2(0.85, 0.85)) * vec2(1.8, 2.2)) * 2.2) * 0.04;
	COLOR = vec4(bg + gold * top_glow + warm * bottom_left + gold * bottom_right, 1.0);
}
