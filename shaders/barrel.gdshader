shader_type canvas_item;

uniform float start_position = 0.0;
uniform float start_angle = 0.0;
uniform float rotation_amplitude: hint_range(0., 3.14) = 0.3;
uniform float rotation_freq : hint_range(0., 10.) = 0.5;
uniform float vertical_amplitude: hint_range(0., 1000.) = 50.;
uniform float vertical_freq: hint_range(0., 10.) = 0.5;
uniform float clip_y: hint_range(0.0, 1.0, 0.1) = 1.0; // from 0.0 (bottom) to 1.0 (top), default no clip

varying float rotation_angle;

vec2 rotate(vec2 uv, float rotation)
{
	mat2 rotation_matrix = mat2(
		vec2(sin(rotation), -cos(rotation)),
		vec2(cos(rotation), sin(rotation))
	);
	return uv * rotation_matrix;
}

void vertex() {
	rotation_angle = cos(2. * PI * TIME * rotation_freq + start_angle);
	VERTEX = rotate(VERTEX, PI / 2. + rotation_amplitude * rotation_angle);
	VERTEX.y += vertical_amplitude * sin(2. * PI * TIME * vertical_freq);
}

