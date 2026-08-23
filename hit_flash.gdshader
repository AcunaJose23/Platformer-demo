shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform bool solid_flash = false;

// NUEVO: Una variable solo para el color de carga de salto
uniform vec4 charge_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); 

void fragment() {
	// Guardamos el color de la textura
	vec4 base = texture(TEXTURE, UV);
	
	// Le aplicamos el color de carga (Amarillo, Rojo o Blanco)
	base = base * charge_color;
	
	if (solid_flash) {
		COLOR = vec4(flash_color.rgb, base.a);
	}
	else if (flash_amount > 0.0) {
		COLOR.rgb = mix(base.rgb, flash_color.rgb, flash_amount);
		COLOR.a = base.a;
	}
	else {
		// Ya no multiplicamos por el COLOR del nodo, evitando que se oscurezca
		COLOR = base; 
	}
}