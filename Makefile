# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.16

# Default target executed when no arguments are given to make.
default_target: all

.PHONY : default_target

# Allow only one "make -f Makefile2" at a time, but pass parallelism.
.NOTPARALLEL:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /media/sdb1/Workspace/DESK/Own_projects_atom/imgui-in-c/chess_imgui

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /media/sdb1/Workspace/DESK/Own_projects_atom/imgui-in-c/chess_imgui

#=============================================================================
# Targets provided globally by CMake.

# Special rule for the target rebuild_cache
rebuild_cache:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --cyan "Running CMake to regenerate build system..."
	/usr/bin/cmake -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR)
.PHONY : rebuild_cache

# Special rule for the target rebuild_cache
rebuild_cache/fast: rebuild_cache

.PHONY : rebuild_cache/fast

# Special rule for the target edit_cache
edit_cache:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --cyan "Running CMake cache editor..."
	/usr/bin/cmake-gui -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR)
.PHONY : edit_cache

# Special rule for the target edit_cache
edit_cache/fast: edit_cache

.PHONY : edit_cache/fast

# The main all target
all: cmake_check_build_system
	$(CMAKE_COMMAND) -E cmake_progress_start /media/sdb1/Workspace/DESK/Own_projects_atom/imgui-in-c/chess_imgui/CMakeFiles /media/sdb1/Workspace/DESK/Own_projects_atom/imgui-in-c/chess_imgui/CMakeFiles/progress.marks
	$(MAKE) -f CMakeFiles/Makefile2 all
	$(CMAKE_COMMAND) -E cmake_progress_start /media/sdb1/Workspace/DESK/Own_projects_atom/imgui-in-c/chess_imgui/CMakeFiles 0
.PHONY : all

# The main clean target
clean:
	$(MAKE) -f CMakeFiles/Makefile2 clean
.PHONY : clean

# The main clean target
clean/fast: clean

.PHONY : clean/fast

# Prepare targets for installation.
preinstall: all
	$(MAKE) -f CMakeFiles/Makefile2 preinstall
.PHONY : preinstall

# Prepare targets for installation.
preinstall/fast:
	$(MAKE) -f CMakeFiles/Makefile2 preinstall
.PHONY : preinstall/fast

# clear depends
depend:
	$(CMAKE_COMMAND) -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR) --check-build-system CMakeFiles/Makefile.cmake 1
.PHONY : depend

#=============================================================================
# Target rules for targets named imgui

# Build rule for target.
imgui: cmake_check_build_system
	$(MAKE) -f CMakeFiles/Makefile2 imgui
.PHONY : imgui

# fast build rule for target.
imgui/fast:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/build
.PHONY : imgui/fast

#=============================================================================
# Target rules for targets named app

# Build rule for target.
app: cmake_check_build_system
	$(MAKE) -f CMakeFiles/Makefile2 app
.PHONY : app

# fast build rule for target.
app/fast:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/build
.PHONY : app/fast

glad.o: glad.c.o

.PHONY : glad.o

# target to build an object file
glad.c.o:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/glad.c.o
.PHONY : glad.c.o

glad.i: glad.c.i

.PHONY : glad.i

# target to preprocess a source file
glad.c.i:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/glad.c.i
.PHONY : glad.c.i

glad.s: glad.c.s

.PHONY : glad.s

# target to generate assembly for a file
glad.c.s:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/glad.c.s
.PHONY : glad.c.s

imgui/imgui.o: imgui/imgui.cpp.o

.PHONY : imgui/imgui.o

# target to build an object file
imgui/imgui.cpp.o:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui.cpp.o
.PHONY : imgui/imgui.cpp.o

imgui/imgui.i: imgui/imgui.cpp.i

.PHONY : imgui/imgui.i

# target to preprocess a source file
imgui/imgui.cpp.i:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui.cpp.i
.PHONY : imgui/imgui.cpp.i

imgui/imgui.s: imgui/imgui.cpp.s

.PHONY : imgui/imgui.s

# target to generate assembly for a file
imgui/imgui.cpp.s:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui.cpp.s
.PHONY : imgui/imgui.cpp.s

imgui/imgui_demo.o: imgui/imgui_demo.cpp.o

.PHONY : imgui/imgui_demo.o

# target to build an object file
imgui/imgui_demo.cpp.o:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_demo.cpp.o
.PHONY : imgui/imgui_demo.cpp.o

imgui/imgui_demo.i: imgui/imgui_demo.cpp.i

.PHONY : imgui/imgui_demo.i

# target to preprocess a source file
imgui/imgui_demo.cpp.i:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_demo.cpp.i
.PHONY : imgui/imgui_demo.cpp.i

imgui/imgui_demo.s: imgui/imgui_demo.cpp.s

.PHONY : imgui/imgui_demo.s

# target to generate assembly for a file
imgui/imgui_demo.cpp.s:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_demo.cpp.s
.PHONY : imgui/imgui_demo.cpp.s

imgui/imgui_draw.o: imgui/imgui_draw.cpp.o

.PHONY : imgui/imgui_draw.o

# target to build an object file
imgui/imgui_draw.cpp.o:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_draw.cpp.o
.PHONY : imgui/imgui_draw.cpp.o

imgui/imgui_draw.i: imgui/imgui_draw.cpp.i

.PHONY : imgui/imgui_draw.i

# target to preprocess a source file
imgui/imgui_draw.cpp.i:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_draw.cpp.i
.PHONY : imgui/imgui_draw.cpp.i

imgui/imgui_draw.s: imgui/imgui_draw.cpp.s

.PHONY : imgui/imgui_draw.s

# target to generate assembly for a file
imgui/imgui_draw.cpp.s:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_draw.cpp.s
.PHONY : imgui/imgui_draw.cpp.s

imgui/imgui_impl_glfw.o: imgui/imgui_impl_glfw.cpp.o

.PHONY : imgui/imgui_impl_glfw.o

# target to build an object file
imgui/imgui_impl_glfw.cpp.o:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_impl_glfw.cpp.o
.PHONY : imgui/imgui_impl_glfw.cpp.o

imgui/imgui_impl_glfw.i: imgui/imgui_impl_glfw.cpp.i

.PHONY : imgui/imgui_impl_glfw.i

# target to preprocess a source file
imgui/imgui_impl_glfw.cpp.i:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_impl_glfw.cpp.i
.PHONY : imgui/imgui_impl_glfw.cpp.i

imgui/imgui_impl_glfw.s: imgui/imgui_impl_glfw.cpp.s

.PHONY : imgui/imgui_impl_glfw.s

# target to generate assembly for a file
imgui/imgui_impl_glfw.cpp.s:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_impl_glfw.cpp.s
.PHONY : imgui/imgui_impl_glfw.cpp.s

imgui/imgui_impl_opengl3.o: imgui/imgui_impl_opengl3.cpp.o

.PHONY : imgui/imgui_impl_opengl3.o

# target to build an object file
imgui/imgui_impl_opengl3.cpp.o:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_impl_opengl3.cpp.o
.PHONY : imgui/imgui_impl_opengl3.cpp.o

imgui/imgui_impl_opengl3.i: imgui/imgui_impl_opengl3.cpp.i

.PHONY : imgui/imgui_impl_opengl3.i

# target to preprocess a source file
imgui/imgui_impl_opengl3.cpp.i:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_impl_opengl3.cpp.i
.PHONY : imgui/imgui_impl_opengl3.cpp.i

imgui/imgui_impl_opengl3.s: imgui/imgui_impl_opengl3.cpp.s

.PHONY : imgui/imgui_impl_opengl3.s

# target to generate assembly for a file
imgui/imgui_impl_opengl3.cpp.s:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_impl_opengl3.cpp.s
.PHONY : imgui/imgui_impl_opengl3.cpp.s

imgui/imgui_tables.o: imgui/imgui_tables.cpp.o

.PHONY : imgui/imgui_tables.o

# target to build an object file
imgui/imgui_tables.cpp.o:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_tables.cpp.o
.PHONY : imgui/imgui_tables.cpp.o

imgui/imgui_tables.i: imgui/imgui_tables.cpp.i

.PHONY : imgui/imgui_tables.i

# target to preprocess a source file
imgui/imgui_tables.cpp.i:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_tables.cpp.i
.PHONY : imgui/imgui_tables.cpp.i

imgui/imgui_tables.s: imgui/imgui_tables.cpp.s

.PHONY : imgui/imgui_tables.s

# target to generate assembly for a file
imgui/imgui_tables.cpp.s:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_tables.cpp.s
.PHONY : imgui/imgui_tables.cpp.s

imgui/imgui_widgets.o: imgui/imgui_widgets.cpp.o

.PHONY : imgui/imgui_widgets.o

# target to build an object file
imgui/imgui_widgets.cpp.o:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_widgets.cpp.o
.PHONY : imgui/imgui_widgets.cpp.o

imgui/imgui_widgets.i: imgui/imgui_widgets.cpp.i

.PHONY : imgui/imgui_widgets.i

# target to preprocess a source file
imgui/imgui_widgets.cpp.i:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_widgets.cpp.i
.PHONY : imgui/imgui_widgets.cpp.i

imgui/imgui_widgets.s: imgui/imgui_widgets.cpp.s

.PHONY : imgui/imgui_widgets.s

# target to generate assembly for a file
imgui/imgui_widgets.cpp.s:
	$(MAKE) -f CMakeFiles/imgui.dir/build.make CMakeFiles/imgui.dir/imgui/imgui_widgets.cpp.s
.PHONY : imgui/imgui_widgets.cpp.s

main.o: main.cpp.o

.PHONY : main.o

# target to build an object file
main.cpp.o:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/main.cpp.o
.PHONY : main.cpp.o

main.i: main.cpp.i

.PHONY : main.i

# target to preprocess a source file
main.cpp.i:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/main.cpp.i
.PHONY : main.cpp.i

main.s: main.cpp.s

.PHONY : main.s

# target to generate assembly for a file
main.cpp.s:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/main.cpp.s
.PHONY : main.cpp.s

stb.o: stb.cpp.o

.PHONY : stb.o

# target to build an object file
stb.cpp.o:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/stb.cpp.o
.PHONY : stb.cpp.o

stb.i: stb.cpp.i

.PHONY : stb.i

# target to preprocess a source file
stb.cpp.i:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/stb.cpp.i
.PHONY : stb.cpp.i

stb.s: stb.cpp.s

.PHONY : stb.s

# target to generate assembly for a file
stb.cpp.s:
	$(MAKE) -f CMakeFiles/app.dir/build.make CMakeFiles/app.dir/stb.cpp.s
.PHONY : stb.cpp.s

# Help Target
help:
	@echo "The following are some of the valid targets for this Makefile:"
	@echo "... all (the default if no target is provided)"
	@echo "... clean"
	@echo "... depend"
	@echo "... rebuild_cache"
	@echo "... edit_cache"
	@echo "... imgui"
	@echo "... app"
	@echo "... glad.o"
	@echo "... glad.i"
	@echo "... glad.s"
	@echo "... imgui/imgui.o"
	@echo "... imgui/imgui.i"
	@echo "... imgui/imgui.s"
	@echo "... imgui/imgui_demo.o"
	@echo "... imgui/imgui_demo.i"
	@echo "... imgui/imgui_demo.s"
	@echo "... imgui/imgui_draw.o"
	@echo "... imgui/imgui_draw.i"
	@echo "... imgui/imgui_draw.s"
	@echo "... imgui/imgui_impl_glfw.o"
	@echo "... imgui/imgui_impl_glfw.i"
	@echo "... imgui/imgui_impl_glfw.s"
	@echo "... imgui/imgui_impl_opengl3.o"
	@echo "... imgui/imgui_impl_opengl3.i"
	@echo "... imgui/imgui_impl_opengl3.s"
	@echo "... imgui/imgui_tables.o"
	@echo "... imgui/imgui_tables.i"
	@echo "... imgui/imgui_tables.s"
	@echo "... imgui/imgui_widgets.o"
	@echo "... imgui/imgui_widgets.i"
	@echo "... imgui/imgui_widgets.s"
	@echo "... main.o"
	@echo "... main.i"
	@echo "... main.s"
	@echo "... stb.o"
	@echo "... stb.i"
	@echo "... stb.s"
.PHONY : help



#=============================================================================
# Special targets to cleanup operation of make.

# Special rule to run CMake to check the build system integrity.
# No rule that depends on this can have commands that come from listfiles
# because they might be regenerated.
cmake_check_build_system:
	$(CMAKE_COMMAND) -S$(CMAKE_SOURCE_DIR) -B$(CMAKE_BINARY_DIR) --check-build-system CMakeFiles/Makefile.cmake 0
.PHONY : cmake_check_build_system

