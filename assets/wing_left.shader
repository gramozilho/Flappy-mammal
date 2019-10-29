shader_type canvas_item;

uniform float wing_position = -1.0;

void vertex() {
	VERTEX.y += wing_position * (VERTEX.x + 70.0) / 2.0;
	VERTEX.x -= wing_position * (VERTEX.y + 80.0) / 10.0;
}