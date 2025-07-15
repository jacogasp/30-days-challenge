shader_type canvas_item;

uniform float clip_y: hint_range(0.0, 1.0, 0.1) = 1.0; // from 0.0 (bottom) to 1.0 (top), default no clip

void fragment() {
    // UV.y goes from 0 (top) to 1 (bottom) by default in Godot
    // So to clip *below* clip_y, discard pixels with UV.y > clip_y
    if (UV.y > clip_y) {
        discard;
    }
    COLOR = texture(TEXTURE, UV) * COLOR;
}
