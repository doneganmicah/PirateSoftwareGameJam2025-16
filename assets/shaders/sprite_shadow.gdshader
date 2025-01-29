shader_type canvas_item;

uniform vec4 shadow_color : source_color;

void fragment() {
	if(texture(TEXTURE, UV).a > 0.0f) COLOR = shadow_color;
}

