shader_type spatial;

// Controla o tamanho visual dos vértices quando renderizados
uniform float point_size : hint_range(1.0, 100.0);

uniform float max_distance = 15.0;
uniform float min_distance = 5.0;

//varying float light_intensity;

varying float half_distance;
varying float vertex_distance;

void vertex() {
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//vec3 camera_position = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 camera_position = CAMERA_POSITION_WORLD;
	vertex_distance = distance(world_position, camera_position);

	half_distance = ((max_distance - min_distance)/2.0) + min_distance;

	// Define o tamanho dos pontos para serem visíveis
    POINT_SIZE = point_size;
}

void fragment() {	
	if(vertex_distance > max_distance){
	// Se estamos processando um vértice, colore com a cor dos vértices
		discard;
	}
	else if (vertex_distance <= max_distance && vertex_distance > half_distance){
		ALBEDO = mix(vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0), clamp(vertex_distance/max_distance, 0, 1));
	}
	else if (vertex_distance > min_distance && vertex_distance <= half_distance){
		ALBEDO = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), clamp(vertex_distance/max_distance, 0, 1));
	} else{
		ALBEDO = vec3(1.0, 0.0, 0.0);
	}
}

void light(){
	DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * (ATTENUATION * 4.0) * LIGHT_COLOR;
}