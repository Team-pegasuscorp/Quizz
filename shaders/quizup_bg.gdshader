shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	// Brand navy canvas — a step lighter than header/FAB (#010010)
	vec3 deep = vec3(0.110, 0.094, 0.188); // #1C1830
	vec3 lift = vec3(0.157, 0.133, 0.255); // #282241
	vec3 bg = mix(deep, lift, uv.y * 0.55);
	// Soft brand glows (cyan / purple / pink)
	vec3 cyan = vec3(0.0, 0.831, 1.0);      // #00D4FF
	vec3 purple = vec3(0.482, 0.380, 1.0);  // #7B61FF
	vec3 pink = vec3(1.0, 0.302, 1.0);      // #FF4DFF
	float glow_l = exp(-length((uv - vec2(-0.08, 0.28)) * vec2(1.2, 1.35)) * 2.0) * 0.10;
	float glow_r = exp(-length((uv - vec2(1.08, 0.18)) * vec2(1.35, 1.7)) * 2.4) * 0.08;
	float glow_b = exp(-length((uv - vec2(0.5, 1.15)) * vec2(1.1, 1.6)) * 2.2) * 0.06;
	COLOR = vec4(bg + cyan * glow_l + purple * glow_r + pink * glow_b, 1.0);
}
