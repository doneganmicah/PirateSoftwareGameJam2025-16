shader_type canvas_item;

uniform sampler2D ground_tex;

void fragment() {
	
	vec4 input_color = texture(ground_tex, UV);
	COLOR.rgb = input_color.rgb;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
