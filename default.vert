#version 330 core

// Positions/Coordinates
layout (location = 0) in vec2 aPos;
// Texture Coordinates
layout (location = 1) in vec2 aTex;


// Outputs the color for the Fragment Shader
out vec3 color;
// Outputs the texture coordinates to the fragment shader
out vec2 texCoord;

// Controls the scale of the vertices
uniform vec2 scale;
uniform vec2 translation;


void main()
{
	// Outputs the positions/coordinates of all vertices
	gl_Position = vec4(aPos.x * scale.x + translation.x , aPos.y * scale.y + translation.y, 1.0, 1.0);
	// Assigns the texture coordinates from the Vertex Data to "texCoord"
	texCoord = aTex;
}
