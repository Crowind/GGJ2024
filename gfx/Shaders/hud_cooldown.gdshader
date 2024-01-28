shader_type canvas_item;

uniform float fill = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	if(UV.y + 0.02f*sin(UV.x *10.f +TIME*10.f) < (1.f-fill) ){
		float grayscale = dot(COLOR.rgb, vec3(0.2126, 0.7152, 0.0722));
		COLOR.rgb = vec3(grayscale,grayscale,grayscale);
	}
	else{
		COLOR.rgb *= vec3(0.05f,0.8f,0.1f);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
