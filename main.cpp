

#include<filesystem>
namespace fs = std::filesystem;

#include<glad/glad.h> //library that allows using opengl functions
#include "imgui.h" //gui library
#include "imgui_impl_glfw.h" //bindings to opengl for the gui
#include "imgui_impl_opengl3.h" //bindings to opengl for the gui
#include <stdio.h>
#if defined(IMGUI_IMPL_OPENGL_ES2)
#include <GLES2/gl2.h>
#endif
#include <GLFW/glfw3.h> // Will drag system OpenGL headers

//to load images
#include<stb/stb_image.h>

//not sure, but i think it for the loading stuff
#include<string>
#include<fstream>
#include<sstream>
#include<iostream>
#include<cerrno>

#include <cmath>
#define PI 3.14159265

//for lua bindings
#define SOL_ALL_SAFETIES_ON 1
#include <sol/sol.hpp>

#include <vector>

#include <filesystem>
#include <unistd.h>


/////////////////////
//Shader stuff
//copied over from a tutorial 


// Reads a text file and outputs a string with everything in the text file
static std::string get_file_contents(const char* filename)
{
	std::ifstream in(filename, std::ios::binary);
	if (in)
	{
		std::string contents;
		in.seekg(0, std::ios::end);
		contents.resize(in.tellg());
		in.seekg(0, std::ios::beg);
		in.read(&contents[0], contents.size());
		in.close();
		return(contents);
	}
	throw(errno);
}

// Checks if the different Shaders have compiled properly
static void Shader_compileErrors(unsigned int shader, const char* type)
{
	// Stores status of compilation
	GLint hasCompiled;
	// Character array to store error message in
	char infoLog[1024];
	if (type != "PROGRAM")
	{
		glGetShaderiv(shader, GL_COMPILE_STATUS, &hasCompiled);
		if (hasCompiled == GL_FALSE)
		{
			glGetShaderInfoLog(shader, 1024, NULL, infoLog);
			std::cout << "SHADER_COMPILATION_ERROR for:" << type << "\n" << infoLog << std::endl;
		}
	}
	else
	{
		glGetProgramiv(shader, GL_LINK_STATUS, &hasCompiled);
		if (hasCompiled == GL_FALSE)
		{
			glGetProgramInfoLog(shader, 1024, NULL, infoLog);
			std::cout << "SHADER_LINKING_ERROR for:" << type << "\n" << infoLog << std::endl;
		}
	}
}


static void Shader_Generate(GLuint &ID, const char* vertexFile, const char* fragmentFile)
{
	// Read vertexFile and fragmentFile and store the strings
	std::string vertexCode = get_file_contents(vertexFile);
	std::string fragmentCode = get_file_contents(fragmentFile);

	// Convert the shader source strings into character arrays
	const char* vertexSource = vertexCode.c_str();
	const char* fragmentSource = fragmentCode.c_str();

	// Create Vertex Shader Object and get its reference
	GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
	// Attach Vertex Shader source to the Vertex Shader Object
	glShaderSource(vertexShader, 1, &vertexSource, NULL);
	// Compile the Vertex Shader into machine code
	glCompileShader(vertexShader);
	// Checks if Shader compiled succesfully
	Shader_compileErrors(vertexShader, "VERTEX");

	// Create Fragment Shader Object and get its reference
	GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	// Attach Fragment Shader source to the Fragment Shader Object
	glShaderSource(fragmentShader, 1, &fragmentSource, NULL);
	// Compile the Vertex Shader into machine code
	glCompileShader(fragmentShader);
	// Checks if Shader compiled succesfully
	Shader_compileErrors(fragmentShader, "FRAGMENT");

	// Create Shader Program Object and get its reference
	ID = glCreateProgram();
	// Attach the Vertex and Fragment Shaders to the Shader Program
	glAttachShader(ID, vertexShader);
	glAttachShader(ID, fragmentShader);
	// Wrap-up/Link all the shaders together into the Shader Program
	glLinkProgram(ID);
	// Checks if Shaders linked succesfully
	Shader_compileErrors(ID, "PROGRAM");

	// Delete the now useless Vertex and Fragment Shader objects
	glDeleteShader(vertexShader);
	glDeleteShader(fragmentShader);

}

static void Shader_Activate(GLuint &ID)
{
	glUseProgram(ID);
}

static void Shader_Delete(GLuint &ID)
{
	glDeleteProgram(ID);
}


//////////////////////
////Textures
//copied over from a tutorial 

typedef struct {
	GLuint ID;
	GLenum type;
	int width;
	int height;
} Texture;


static void Texture_Generate(Texture &texture, const char* image, GLenum texType, GLenum slot, GLenum format, GLenum pixelType)
{
	// Assigns the type of the texture ot the texture object
	texture.type = texType;

	// Stores the width, height, and the number of color channels of the image
	int widthImg, heightImg, numColCh;
	// Flips the image so it appears right side up
	stbi_set_flip_vertically_on_load(true);
	// Reads the image from a file and stores it in bytes
	unsigned char* bytes = stbi_load(image, &widthImg, &heightImg, &numColCh, 4);
	
	texture.width = widthImg;
	texture.height = heightImg;

	// Generates an OpenGL texture object
	glGenTextures(1, &texture.ID);
	// Assigns the texture to a Texture Unit
	glActiveTexture(slot);
	glBindTexture(texType, texture.ID);

	// Configures the type of algorithm that is used to make the image smaller or bigger
	glTexParameteri(texType, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(texType, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	// Configures the way the texture repeats (if it does at all)
	glTexParameteri(texType, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(texType, GL_TEXTURE_WRAP_T, GL_REPEAT);

	// Extra lines in case you choose to use GL_CLAMP_TO_BORDER
	// float flatColor[] = {1.0f, 1.0f, 1.0f, 1.0f};
	// glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, flatColor);

	// Assigns the image to the OpenGL Texture object
	glTexImage2D(texType, 0, GL_RGBA, widthImg, heightImg, 0, format, pixelType, bytes);
	// Generates MipMaps
	glGenerateMipmap(texType);

	// Deletes the image data as it is already in the OpenGL Texture object
	stbi_image_free(bytes);

	// Unbinds the OpenGL Texture object so that it can't accidentally be modified
	glBindTexture(texType, 0);
}

static void Texture_texUnit(GLuint &shader, const char* uniform, GLuint unit)
{
	// Gets the location of the uniform
	GLuint texUni = glGetUniformLocation(shader, uniform);
	// Shader needs to be activated before changing the value of a uniform
	Shader_Activate(shader);
	// Sets the value of the uniform
	glUniform1i(texUni, unit);
}

static void Texture_Bind(Texture &texture)
{
	glBindTexture(texture.type, texture.ID);
}

static void Texture_Unbind(Texture &texture)
{
	glBindTexture(texture.type, 0);
}

static void Texture_Delete(Texture &texture)
{
	glDeleteTextures(1, &texture.ID);
}


////////////
////////////////////////
//VBO stuff

typedef struct {
	GLuint ID;
	float width;
	float height;
} VBO;

static void VBO_Bind(VBO &VBO_ID)
{
	glBindBuffer(GL_ARRAY_BUFFER, VBO_ID.ID);
}
static void VBO_Unbind()
{
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}
static void VBO_Delete(VBO &VBO_ID)
{
	glDeleteBuffers(1, &VBO_ID.ID);
}

static void VBO_Generate(VBO &VBO_ID, GLfloat* vertices, GLsizeiptr size)
{
	glGenBuffers(1, &VBO_ID.ID);
	glBindBuffer(GL_ARRAY_BUFFER, VBO_ID.ID);
	glBufferData(GL_ARRAY_BUFFER, size, vertices, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

static void VBO_New_Vertices(VBO &VBO_ID, GLfloat* vertices, GLsizeiptr size, GLintptr offset)
{
	glBindBuffer(GL_ARRAY_BUFFER, VBO_ID.ID);
	glBufferSubData(GL_ARRAY_BUFFER, offset, size, vertices);
}

/*static void VBO_LinkAttrib(GLuint &VBO, GLuint layout, GLuint numComponents, GLenum type, GLsizeiptr stride, void* offset)
{
	VBO_Bind(VBO);
	glVertexAttribPointer(layout, numComponents, type, GL_FALSE, stride, offset);
	glEnableVertexAttribArray(layout);
	VBO_Unbind();
}*/


///////////////////
////////////////////////
//VAO stuff

//tells opengl the format of our data
static void VAO_LinkAttrib(GLuint &VAO)
{
	glBindVertexArray(VAO);
	//still a bit confused by the meaning of glVertexAttribBinding. here for future me: https://stackoverflow.com/questions/66653211/with-opengl-4-3-how-do-i-correctly-use-glvertexattribformat-binding 
	glVertexAttribFormat(0, 2, GL_FLOAT, GL_FALSE, 0);
	glVertexAttribBinding(0, 0);
	glVertexAttribFormat(1, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float));
	glVertexAttribBinding(1, 0);
	
	glEnableVertexAttribArray(0);
	glEnableVertexAttribArray(1);
	glBindVertexArray(0);
}

static void VAO_Bind(GLuint &VAO_ID)
{
	glBindVertexArray(VAO_ID);
}
static void VAO_Unbind()
{
	glBindVertexArray(0);
}
static void VAO_Delete(GLuint &VAO_ID)
{
	glDeleteVertexArrays(1, &VAO_ID);
}

static void VAO_Generate(GLuint &VAO_ID)
{
	glGenVertexArrays(1, &VAO_ID);
}

///////////////////
////////////////////////
//EBO stuff


static void EBO_Bind(GLuint &EBO_ID)
{
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO_ID);
}
static void EBO_Unbind()
{
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}
static void EBO_Delete(GLuint &EBO_ID)
{
	glDeleteBuffers(1, &EBO_ID);
}

static void EBO_Generate(GLuint &EBO_ID, GLuint* indices, GLsizeiptr size)
{
	glGenBuffers(1, &EBO_ID);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO_ID);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, indices, GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

///////////////////



/////////////////////////////
static void glfw_error_callback(int error, const char* description)
{
    fprintf(stderr, "Glfw Error %d: %s\n", error, description);
}


// Vertices coordinates
GLfloat vertices[] =
{ //     COORDINATES        /   TexCoord  //
	 0.0f,  0.0f,   0.0f, 0.0f,  // Lower left corner
	 0.0f,  1.0f,   0.0f, 1.0f,  // Upper left corner
	 1.0f,  0.0f,   1.0f, 0.0f,  // Lower right corner
	 1.0f,  1.0f,   1.0f, 1.0f, // Upper right corner
};

// Indices for vertices order
GLuint indices[] =
{
	0, 1, 2, 3
};


int main(int, char**)
{
		
    // Setup window
    glfwSetErrorCallback(glfw_error_callback);
    if (!glfwInit())
        return 1;


    // Create window with graphics context
    GLFWwindow* window = glfwCreateWindow(800, 800, "Chess", NULL, NULL);
    if (window == NULL)
        return 1;
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1); // Enable vsync
    

		gladLoadGL();

		    // Decide GL+GLSL versions
#if defined(IMGUI_IMPL_OPENGL_ES2)
    // GL ES 2.0 + GLSL 100
    const char* glsl_version = "#version 100";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    glfwWindowHint(GLFW_CLIENT_API, GLFW_OPENGL_ES_API);
#elif defined(__APPLE__)
    // GL 3.2 + GLSL 150
    const char* glsl_version = "#version 150";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);  // 3.2+ only
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);            // Required on Mac
#else
    // GL 3.0 + GLSL 130
    const char* glsl_version = "#version 130";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    //glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);  // 3.2+ only
    //glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);            // 3.0+ only
#endif


    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    ImGui::StyleColorsDark();
    //ImGui::StyleColorsClassic();

    // Setup Platform/Renderer backends
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init(glsl_version);


		GLuint shaderProgram;
		Shader_Generate(shaderProgram, "default.vert", "default.frag");
		
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	

		GLuint defaultVAO;
		VAO_Generate(defaultVAO);
		VAO_Bind(defaultVAO);


		VBO squareVBO;
		VBO_Generate(squareVBO, vertices, sizeof(vertices));

		GLuint squareEBO;
		EBO_Generate(squareEBO, indices, sizeof(indices));
		
		
		VAO_LinkAttrib(defaultVAO);
		
		// Unbind all to prevent accidentally modifying them
		VAO_Unbind();
		EBO_Unbind();

		//getting the uniform IDs
		GLuint scaleID = glGetUniformLocation(shaderProgram, "scale");
		GLuint translationID = glGetUniformLocation(shaderProgram, "translation");
		GLuint colourID = glGetUniformLocation(shaderProgram, "colour");
		GLuint hasTextureID = glGetUniformLocation(shaderProgram, "hasTexture");
		
		//setting up the function to be used by the Lua code

		std::vector<Texture> imgs;
		auto loadImage = [&](std::string path) -> int
		{ 
			Texture t;
			Texture_Generate(t, path.c_str(), GL_TEXTURE_2D, GL_TEXTURE0, GL_RGBA, GL_UNSIGNED_BYTE);
			imgs.push_back(t); 
			return imgs.size()-1; //this needs to change when I allow deleting loaded images. not needed now
		};
		
		std::vector<VBO> VBOs;
		VBOs.push_back(squareVBO);
		auto addVBO = [&](float x, float y, float w, float h) -> int
		{
			VBO temp;
			//HACKY SOLUTION BELOW!!!
			// On the LOVE engine, everything renders nicely. But here, there was a thin strip of unwanted pixels above the image.
			// to fix this, I just slice a little bit off the top of the quad by multiplying by 0.99.
			//this isn't great, but its  the quick solution
						// Vertices coordinates
			GLfloat v[16] =
			{ //     COORDINATES        /   TexCoord  //
				 0.0f,  0.0f,   x, y,  // Lower left corner
				 0.0f,  1.0f,   x,  y+0.99f *h,  // Upper left corner
				 1.0f,  0.0f,   x+w, y,  // Lower right corner
				 1.0f,  1.0f,   x+w, y+0.99f *h, // Upper right corner
			};
			
			VBO_Generate(temp, v, sizeof(v));
			temp.width = w;
			temp.height = h;
			VBOs.push_back(temp); 
			return VBOs.size()-1; //this needs to change when I allow deleting loaded images. not needed now
		};
		
		//////TRANSLATION
		float tx = -1;
		float ty = -1;
		
		auto drawImage = [&](int imgID, double x, double y, double sx, double sy, int vboID) 
		{
			EBO_Bind(squareEBO);
			glBindVertexBuffer(0, VBOs[vboID].ID, 0, 4 * sizeof(float));
			
			Texture_Bind(imgs[imgID]);
			glUniform2f(scaleID, sx * ((float) imgs[imgID].width) * VBOs[vboID].width, sy* ((float) imgs[imgID].height)*VBOs[vboID].height);
			glUniform2f(translationID, x+tx, y+ty);
			glUniform1i(hasTextureID, 1);
			glUniform1i(glGetUniformLocation(shaderProgram, "tex"), 0);
			
			glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, 0);
		};
		
		
		auto drawRectangle = [&](double x, double y, double sx, double sy, float r, float g, float b, float a = 1.0) 
		{
			EBO_Bind(squareEBO);
			glBindVertexBuffer(0, VBOs[0].ID, 0, 4 * sizeof(float));
			
			glUniform2f(scaleID, sx, sy);
			glUniform2f(translationID, x+tx, y+ty);
			glUniform4f(colourID, r, g, b, a);
			glUniform1i(hasTextureID, 0);
			glUniform1i(glGetUniformLocation(shaderProgram, "tex"), 0);
			
			glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, 0);
		};
		
		///////////////circle stuff. could be better. look at: http://www.humus.name/index.php?page=News&ID=228
		int temp = 200;
		GLfloat circleVertex[temp+4];
		double ttemp;
		
		GLuint circleIndices[temp/4+2]; 
		
			circleVertex[0] = 0;
			circleVertex[1] = 0;
			circleVertex[2] = 0;
			circleVertex[3] = 0;
			
		
		for (int i = 0; i < temp/4; i++)
		{
			ttemp = ((float)i)/((float)(temp/4)) * 2.0 * PI;
			circleVertex[4*i+4]   = cos(ttemp);
			circleVertex[4*i+1+4] = sin(ttemp);
			circleVertex[4*i+2+4] = cos(ttemp);
			circleVertex[4*i+3+4] = sin(ttemp);

			circleIndices[i] = i;
		}
		circleIndices[temp/4] = temp/4;
		circleIndices[temp/4+1] = 1;
		
		VBO circleVBO;
		VBO_Generate(circleVBO, circleVertex, sizeof(circleVertex));
		VBOs.push_back(circleVBO); 
		
		GLuint circleEBO;
		EBO_Generate(circleEBO, circleIndices, sizeof(circleIndices));
		//////////////////////////////
		
		//IDEA: instead of drawing a circle, draw a texture with a circle? is faster or no?
		auto drawCircle = [&](double x, double y, double R, float r, float g, float b, float a = 1.0)
		{
		
			EBO_Bind(circleEBO);
			glBindVertexBuffer(0, circleVBO.ID, 0, 4 * sizeof(float));
			
			glUniform2f(scaleID, R, R);
			glUniform2f(translationID, x+tx, y+ty);
			glUniform4f(colourID, r, g, b, a);
			glUniform1i(hasTextureID, 0);
			glUniform1i(glGetUniformLocation(shaderProgram, "tex"), 0);
			
			glDrawElements(GL_TRIANGLE_FAN, temp/4+2, GL_UNSIGNED_INT, 0);
		};
		
		/////// LUA BINDINGS!!!
		sol::state lua;
		
		//the libraries we need loaded
		lua.open_libraries(sol::lib::base, sol::lib::package, sol::lib::table, sol::lib::string, sol::lib::math);
		
		//copied the error handling code from the Sol2 example
		auto errorHandler = [](lua_State*, sol::protected_function_result pfr) {
			// pfr will contain things that went wrong, for either loading or executing the script
			// the user can do whatever they like here, including throw. Otherwise...
			sol::error err = pfr;
			std::cout << "An error (an expected one) occurred: " << err.what() << std::endl;

			// ... they need to return the protected_function_result
			return pfr;
		};
		
		//declare the C functions our game needs in our Lua environment
		lua["get_dimensions"] = [&](int imgID) 
		{
			return std::make_tuple(imgs[imgID].width, imgs[imgID].height);
		};
		lua["draw_circle"] = drawCircle;
		lua["load_image"] = loadImage;
		lua["quad"] = [&](float x, float y, float w, float h, float sw, float sh) -> int
		{
			return addVBO(x/sw, y/sh, w/sw, h/sh);
		};
		lua["draw_image"] = drawImage;
		lua["draw_rectangle"] = drawRectangle;
		
		//package these function in a table and send that table over to our game
		lua.safe_script(
		"funcs = {load_image, quad, draw_rectangle, draw_image, draw_circle, get_dimensions}"
		"chessdraw = require(\"draw\")"
		, errorHandler);
		//load the game!
		lua.safe_script("chessgame = chessdraw(funcs, 2, 2)", errorHandler);
		
		
		//Variables for ImGui
		bool show_menu = false;
    ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);

    // Main loop
    while (!glfwWindowShouldClose(window))
    {
    
        glfwPollEvents();

        // Start the Dear ImGui frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

				//Toggle the menu with escape 
				if(ImGui::IsKeyPressed(ImGui::GetKeyIndex(ImGuiKey_Escape)))
					show_menu = !show_menu;
					
				//shows a small menu to undo or create a new game
        if (show_menu)
        {
						
            ImGui::Begin("Menu");   
						if (ImGui::Button("Restart"))  
							lua.safe_script("chessgame = chessdraw(funcs, 2, 2)", errorHandler);
						
						if (ImGui::Button("Undo"))  
							lua.safe_script("chessgame.undo()", errorHandler);
							
            ImGui::End();
        }
  

				
				// Rendering
				ImGui::Render();
				int display_w, display_h;
				glfwGetFramebufferSize(window, &display_w, &display_h);
				glViewport(0, 0, display_w, display_h);
				glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
				glClear(GL_COLOR_BUFFER_BIT);


				Shader_Activate(shaderProgram);
				VAO_Bind(defaultVAO);
				
				lua.safe_script("chessgame.draw()", errorHandler);
				
				ImGuiIO imguiVariables = ImGui::GetIO();
				
				//handles input for the chess game
				//if the mouse isnt over ImGui UI and the left mouse button is clicked
				//then call the mousepressed function in Lua
				if(imguiVariables.MouseClicked[0] and !imguiVariables.WantCaptureMouse)
				{
					ImVec2 xy = imguiVariables.MousePos;
					std::string x = std::to_string(xy.x);
					std::string y = std::to_string(xy.y);
					int wwidth, wheight;
					glfwGetWindowSize(window, &wwidth, &wheight);
					std::string swwidth = std::to_string(wwidth);
					std::string swheight = std::to_string(wheight);
					lua.safe_script("chessgame.mousepressed("+x+", "+y+""+", "+swwidth+", "+swheight+", false, true)", errorHandler);
				}
		
				//draws the ImGui UI
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

        glfwSwapBuffers(window);
    }

		// Cleanup
		VAO_Delete(defaultVAO);
		
		for (int i = 0; i < VBOs.size(); i++)
			VBO_Delete(VBOs[i]);
			
		EBO_Delete(squareEBO);
		EBO_Delete(circleEBO);
		
		
		for (int i = 0; i < imgs.size(); i++)
			Texture_Delete(imgs[i]);
			
		Shader_Delete(shaderProgram);
			
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
