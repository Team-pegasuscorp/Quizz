shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	vec3 white = vec3(1.0, 1.0, 1.0);
	vec3 mist = vec3(0.96, 0.97, 0.985);
	vec3 bg = mix(white, mist, uv.y * 0.45);
	vec3 cyan = vec3(0.55, 0.82, 0.95);
	vec3 lav = vec3(0.82, 0.80, 0.96);
	float glow_l = exp(-length((uv - vec2(-0.05, 0.35)) * vec2(1.15, 1.4)) * 2.2) * 0.08;
	float glow_r = exp(-length((uv - vec2(1.05, 0.12)) * vec2(1.4, 1.8)) * 2.6) * 0.05;
	COLOR = vec4(bg + cyan * glow_l + lav * glow_r, 1.0);
}
