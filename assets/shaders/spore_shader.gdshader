shader_type canvas_item;

uniform vec4 color : source_color;
uniform sampler2D tex;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR.rgb = color.rgb * tex_color.rgb;
	if(tex_color.a == 1.0f){
		COLOR.a = color.a;
	}
	
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
