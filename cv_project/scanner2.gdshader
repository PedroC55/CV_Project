shader_type spatial;

// Controla o tamanho visual dos vértices quando renderizados
uniform float point_size : hint_range(1.0, 100.0);

uniform float max_distance = 15.0;

uniform float min_distance = 5.0;

varying float half_distance;

varying float vertex_distance;

varying float is_visible;

void vertex() {
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 camera_position = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vertex_distance = distance(world_position, camera_position);

	half_distance = ((max_distance - min_distance)/2.0) + min_distance;
}

void fragment() {
    //if (is_visible < 0.5) {
   //     ALBEDO = vec3(0., 0., 0.); // Descartar fragmentos que não estão visíveis
   //}
    int spacing = 20; //isto dá o espaçamento entre pontos
    int p_size_radius = 4; // isto é o raio do "ponto". O ponto ocupa 2 * p_size_radius +1
	
	//vec3 normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	//vec3 normal = normalize(NORMAL);
	//vec3 light_direction = normalize((INV_VIEW_MATRIX * vec4(LIGHT_VERTEX, 0.0)).xyz);
    if (
        (int(FRAGCOORD.x)%spacing < p_size_radius  || int(FRAGCOORD.x)%spacing > spacing - p_size_radius )
        &&
        (int(FRAGCOORD.y)%spacing < 2 || int(FRAGCOORD.y)%spacing > spacing - p_size_radius)) {

        // Se estamos processando um vértice, colore com a cor dos vértices
		float light_intensity = clamp(dot(NORMAL, -LIGHT_VERTEX), 0.0, 1.0);
		if (light_intensity <= 0.0)
		{
	        discard;
		}
        if(vertex_distance > max_distance){
            ALBEDO = vec3(0., 0., 0.);
			EMISSION = vec3(0., 0., 0.);
        }
        else if (vertex_distance <= max_distance && vertex_distance > half_distance){
            ALBEDO = mix(vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0), clamp(vertex_distance/max_distance, 0, 1));
			EMISSION = mix(vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0), clamp(vertex_distance/max_distance, 0, 1));
        }
        else if (vertex_distance > min_distance && vertex_distance <= half_distance){
            ALBEDO = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), clamp(vertex_distance/max_distance, 0, 1));
			EMISSION = mix(vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), clamp(vertex_distance/max_distance, 0, 1));
        } else{
            ALBEDO = vec3(1.0, 0.0, 0.0);
			EMISSION = vec3(1.0, 0.0, 0.0);
        }

    }
    else
    {
    	ALBEDO = vec3(0., 0., 0.);
		EMISSION = vec3(0., 0., 0.);

    }
}

void light(){
	float light_intensity = clamp(dot(NORMAL, -LIGHT), 0.0, 1.0);
	if (light_intensity <= 0.0)
	{
        discard;
	}
	else{
		DIFFUSE_LIGHT = vec3(1.0);
	}
}