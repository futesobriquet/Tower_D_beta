extern Image normalTexture;
extern vec3 LightPos[];
extern vec3 LightColor[];
extern float numLights;
extern bool useNormalMap;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec3 normal;  // use normal texture when supported
	if(useNormalMap == true) {
		normal = Texel(normalTexture, texture_coords).xyz;
		normal.y = 1 - normal.y;
		normal.x = 1 - normal.x;
		normal = normalize( normal*2 - 1);	
	} else {
		normal = vec3(0, 0, 1);
	}
    vec4 DiffuseColor = Texel(texture, texture_coords); 
	vec4 Ambient = vec4(.5, .5, .5, DiffuseColor.a);
	if(numLights == 0) {
		return DiffuseColor * Ambient;
	}
	
	vec4 Diffuse = vec4(0, 0, 0, 0);
	vec4 Intensity = vec4(0, 0, 0, 0);
	vec4 FinalColor = vec4(0, 0, 0, 0);
	Intensity += Ambient;
	for(int i = 0; i < numLights; i++) {
		vec3 position;
		vec3 color;
		if(i == 0) { position = LightPos[0]; color = LightColor[0];}
		if(i == 1) { position = LightPos[1]; color = LightColor[1];}
		if(i == 2) { position = LightPos[2]; color = LightColor[2];}
		if(i == 3) { position = LightPos[3]; color = LightColor[3];}
		if(i == 4) { position = LightPos[4]; color = LightColor[4];}
		if(i == 5) { position = LightPos[5]; color = LightColor[5];}
		if(i == 6) { position = LightPos[6]; color = LightColor[6];}
		if(i == 7) { position = LightPos[7]; color = LightColor[7];}
		if(i == 8) { position = LightPos[8]; color = LightColor[8];}
		if(i == 9) { position = LightPos[9]; color = LightColor[9];}
		if(i == 10) { position = LightPos[10]; color = LightColor[10];}
		if(i == 11) { position = LightPos[11]; color = LightColor[11];}
		vec3 LightDir = position - vec3(screen_coords, 0);

		float D = length(LightDir);

		vec3 N = normal;
		vec3 L = normalize(LightDir);

		Diffuse = vec4((color.rgb) * max(dot(N, L), 0.0), DiffuseColor.a);

		float Attenuation = 100.0 / D;

		Intensity += (Diffuse * Attenuation);
		
	}
	FinalColor += (DiffuseColor.rgba * Intensity);
    return (FinalColor);
}