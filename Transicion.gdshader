shader_type canvas_item;

// 0.0 = Pantalla limpia (juego), 1.0 = Pantalla negra
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Aquí controlas qué tan grandes son los rombos (en píxeles).
// ¡Prueba subirlo a 60.0 o bajarlo a 20.0 para ver qué estilo te gusta más!
uniform float diamond_size = 40.0; 

void fragment() {
    // Usamos 'fract' para cortar la pantalla en cientos de cuadritos repetidos
    float x = fract(FRAGCOORD.x / diamond_size) - 0.5;
    float y = fract(FRAGCOORD.y / diamond_size) - 0.5;
    
    // Calculamos la forma del rombo en cada cuadrito
    float dist = abs(x) + abs(y);
    
    // Si la distancia es menor al progreso, el rombo negro crece.
    // Multiplicamos por 1.1 para asegurar que las esquinas se tapen por completo.
    if (dist < progress * 1.1) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); // Negro opaco
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Transparente (se ve tu nivel)
    }
}