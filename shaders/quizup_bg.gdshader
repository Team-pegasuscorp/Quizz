shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	vec3 top = vec3(0.278, 0.290, 0.306);    // #474A4E
	vec3 bottom = vec3(0.157, 0.165, 0.176); // #282A2D
	vec3 bg = mix(bottom, top, uv.y);
	vec3 highlight = vec3(0.380, 0.392, 0.408);
	float top_glow = exp(-length((uv - vec2(0.5, 0.0)) * vec2(1.1, 2.4)) * 2.2) * 0.07;
	float orb_left = exp(-length((uv - vec2(0.12, 0.72)) * vec2(1.8, 2.0)) * 2.0) * 0.05;
	float orb_right = exp(-length((uv - vec2(0.88, 0.18)) * vec2(1.6, 1.8)) * 2.4) * 0.04;
	COLOR = vec4(bg + highlight * (top_glow + orb_left + orb_right), 1.0);
}
