shader_type canvas_item;

uniform float waveAmplitude: hint_range(0.0, 1.0) = 0.25;
uniform bool correctVertex = true;
uniform float waveFrequency: hint_range(0.0, 100.0) = 6.0; // Must be whole number for seamless wrap
uniform bool verticalWave = true;
uniform bool keepTransparency = true;
uniform bool useTime = true;
uniform float waveSpeed: hint_range(0.0, 100.0) = 1.0;
uniform float progress: hint_range(0.0, 1.0) = 0.0;
uniform float firstHalf: hint_range(0.0, 1.0) = 0.5;
uniform float secondHalf: hint_range(0.0, 1.0) = 0.5;
uniform bool freezeFirstHalf = false;
uniform bool freezeSecondHalf = false;

void vertex() {
	if (correctVertex) {
		VERTEX = (verticalWave ? vec2(VERTEX.x, VERTEX.y * (1.0 + waveAmplitude)) : vec2(VERTEX.x * (1.0 + waveAmplitude), VERTEX.y));
	}
}

void fragment() {
	vec2 uv = UV;
	float waveUv = (verticalWave ? uv.x : uv.y);
	float againstWaveUv = (verticalWave ? uv.y : uv.x);
	float freezeFactor = 1.0;
	if (freezeFirstHalf) { freezeFactor = waveUv; }
	else if (freezeSecondHalf) { freezeFactor = 1.0 - waveUv; }

	if (againstWaveUv < firstHalf || againstWaveUv > 1.0 - secondHalf) {
		float t = useTime ? TIME * waveSpeed : progress * 2.0 * PI;

		// Use only sine waves with integer-based frequencies so the pattern loops every 1.0 UV
		float wave = 0.0;
		wave += sin(waveUv * waveFrequency * 2.0 * PI + t);                  // Base wave
		wave += 0.5 * sin(waveUv * waveFrequency * 4.0 * PI - t * 1.3);      // Double freq
		wave += 0.25 * sin(waveUv * waveFrequency * 1.0 * PI + t * 2.2);     // Half freq

		wave /= (1.0 + 0.5 + 0.25); // normalize

		wave *= freezeFactor * (waveAmplitude / 4.0);

		vec2 aspect = vec2(TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y, 1.0);
		vec2 center = 0.5 * aspect;

		uv -= center;
		if (verticalWave) {
			uv.y += wave;
			uv.y += uv.y * waveAmplitude;
		} else {
			uv.x += wave;
			uv.x += uv.x * waveAmplitude;
		}
		uv += center;

		uv = clamp(uv, vec2(0.0), vec2(1.0));
		againstWaveUv = (verticalWave ? uv.y : uv.x);
		vec4 texColor = texture(TEXTURE, uv);

		if (keepTransparency) {
			if (againstWaveUv <= 0.0 || againstWaveUv >= 1.0) {
				COLOR.a = 0.0;
			} else {
				COLOR = texColor;
			}
		} else {
			COLOR = texColor;
		}
	}
}
