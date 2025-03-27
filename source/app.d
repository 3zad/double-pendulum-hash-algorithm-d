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

void main() {
    SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
    SetConfigFlags(ConfigFlags.FLAG_WINDOW_ALWAYS_RUN);
    InitWindow(1024, 1024, "Double pendulum simulation");
    // High FPS to allow smooth and accurate simulations (possible to set dt smaller)
    SetTargetFPS(10_000);

    scope (exit) CloseWindow();

    auto d1 = new DoublePendulum("password123!");
    auto d2 = new DoublePendulum("password124!");

    int originX, originY;

    while (!WindowShouldClose) {
        
        originX = GetScreenWidth()/2;
        originY = GetScreenHeight()/2;
        
        BeginDrawing();

        d1.draw(originX, originY);
        d2.draw(originX, originY);

        EndDrawing();
    }
}
