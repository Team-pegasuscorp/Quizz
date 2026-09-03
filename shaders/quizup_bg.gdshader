shader_type canvas_item;

// Fond clair "premium" mais réellement visible :
// dégradé vertical, deux halos d'angle cyan/lavande, légère vignette basse.

void fragment() {
	vec2 uv = UV;

	vec3 top = vec3(1.0, 1.0, 1.0);
	vec3 bottom = vec3(0.925, 0.945, 0.985);
	vec3 bg = mix(top, bottom, smoothstep(0.0, 1.0, uv.y));

	vec3 cyan = vec3(0.42, 0.78, 0.95);
	vec3 lav = vec3(0.74, 0.72, 0.97);

	float glow_l = exp(-length((uv - vec2(-0.05, 0.28)) * vec2(1.05, 1.25)) * 2.0) * 0.22;
	float glow_r = exp(-length((uv - vec2(1.08, 0.08)) * vec2(1.2, 1.5)) * 2.3) * 0.16;

	vec3 col = bg + cyan * glow_l + lav * glow_r;

	// vignette basse pour asseoir la barre de navigation
	float vignette = smoothstep(0.72, 1.0, uv.y) * 0.05;
	col -= vignette;

	COLOR = vec4(col, 1.0);
}
