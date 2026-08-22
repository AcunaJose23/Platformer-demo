shader_type canvas_item;

void vertex() {
	// MODEL_MATRIX[3].x nos da la posición X de esta moneda en el mundo real.
	// Lo multiplicamos por un número pequeño (0.05) para que el desfase no sea tan brusco.
	float desfase = MODEL_MATRIX[3].x * 0.05;
	
	// Le sumamos el desfase al TIEMPO. ¡Ahora cada moneda tiene su propio reloj interno!
	VERTEX.y += sin((TIME * 4.0) + desfase);
}