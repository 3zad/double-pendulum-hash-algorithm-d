import raylib;

import std.math.trigonometry;
import std.conv;
import std.stdio;
import std.math;
import std.math.constants;
import std.format;

import hash_components;
import pure_implementation;
import double_pendulum;
import collisiontest;

void main() {

    SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
    SetConfigFlags(ConfigFlags.FLAG_WINDOW_ALWAYS_RUN);
    InitWindow(1024, 1024, "Double pendulum simulation");
    // High FPS to allow smooth and accurate simulations (possible to set dt smaller)
    SetTargetFPS(100);

    scope (exit) CloseWindow();

    DoublePendulum[] pendulums;

    for (int i = 0; i < 10; i++) {
        pendulums ~= new DoublePendulum(to!string(i));
    }

    int originX, originY;

    while (!WindowShouldClose) {
        
        originX = GetScreenWidth()/2;
        originY = GetScreenHeight()/2;
        
        BeginDrawing();

        for (int i = 0; i < pendulums.length; i++) {
            pendulums[i].draw(originX, originY);
        }

        EndDrawing();
    }
}
