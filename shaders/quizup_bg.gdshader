shader_type canvas_item;

void fragment() {
	vec2 uv = UV;
	vec3 top = vec3(0.071, 0.094, 0.180);    // #12182E
	vec3 bottom = vec3(0.027, 0.039, 0.078); // #070A14
	vec3 bg = mix(bottom, top, uv.y);
	vec3 cyan = vec3(0.0, 0.831, 1.0);       // #00D4FF
	vec3 purple = vec3(0.482, 0.380, 1.0);   // #7B61FF
	vec3 pink = vec3(1.0, 0.302, 1.0);       // #FF4DFF
	float top_glow = exp(-length((uv - vec2(0.5, -0.05)) * vec2(1.05, 2.2)) * 2.0) * 0.16;
	float orb_left = exp(-length((uv - vec2(0.08, 0.78)) * vec2(1.7, 2.0)) * 2.0) * 0.12;
	float orb_right = exp(-length((uv - vec2(0.92, 0.22)) * vec2(1.5, 1.7)) * 2.2) * 0.14;
	COLOR = vec4(bg + cyan * top_glow + pink * orb_left + purple * orb_right, 1.0);
}
