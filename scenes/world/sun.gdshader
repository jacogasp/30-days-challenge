shader_type canvas_item;

// Y coordinate (normalized 0.0–1.0) where blur and fade starts
uniform float blur_start_y : hint_range(0.0, 1.0) = 0.5;
// How much it fades to transparency at the bottom
uniform float fade_strength : hint_range(0.0, 1.0) = 1.0;
// how quickly the blur ends
uniform float blur_distance : hint_range(0.1, 2.0) = 0.4;

void fragment() {
	vec2 uv = UV;
	vec4 col = texture(TEXTURE, uv);

	// Normalize the fade progress (0 at start, 1 at bottom)
	float fade_factor = smoothstep(blur_start_y, blur_start_y + blur_distance , uv.y);

	// Blur with 9-tap box blur (only applied based on fade_factor)
	vec4 blurred = vec4(0.0);
	float offset = fade_factor * TEXTURE_PIXEL_SIZE.y;
	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++) {
			vec2 sample_uv = uv + vec2(float(i), float(j)) * offset;
			blurred += texture(TEXTURE, sample_uv);
		}
	}
	blurred /= 9.0;

	// Mix original with blurred based on fade_factor
	vec4 final_color = mix(col, blurred, fade_factor);

	// Fade alpha as well
	final_color.a *= mix(1.0, 0.0, fade_factor * fade_strength);

	COLOR = final_color * COLOR;
}
