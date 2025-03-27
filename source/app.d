import raylib;

import std.math.trigonometry;
import std.conv;
import std.stdio;
import std.math;
import std.math.constants;
import std.format;

import hash_components;
import pure_implementation;

void main() {
    //benchmark();

    double omega1, omega2, theta1, theta2;
    
    setSartingVariables("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab", &omega1, &omega2, &theta1, &theta2);

    auto d = new DoublePendulum(omega1, omega2, 200, 200, 10, 10, theta1, theta2, 9.81);
    d.run();
}

class DoublePendulum {
    private:
    double omega1;
    double omega2;

    double l1;
    double l2;

    double m1;
    double m2;

    double theta1;
    double theta2;

    double g;

    double dt;

    int[][] breadcrumbs;

    ubyte[] byteStream;

    int originX = 256, originY = 256;

    public:
    this(double omega1, double omega2, double length1, double length2, 
        double mass1, double mass2,
        double theta1, double theta2,
        double gravity) {
        this.omega1 = omega1;
        this.omega2 = omega2;

        this.l1 = length1;
        this.l2 = length2;
        this.m1 = mass1;
        this.m2 = mass2;
        this.theta1 = theta1;
        this.theta2 = theta2;
        this.g = gravity;
        this.dt = 0.01;

        this.breadcrumbs = [];
        this.byteStream = [];
    }

    void run() {
        SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
        SetConfigFlags(ConfigFlags.FLAG_WINDOW_ALWAYS_RUN);
        InitWindow(512, 512, "Double pendulum simulation");
        // High FPS to allow smooth and accurate simulations (possible to set dt smaller)
        SetTargetFPS(100_000);

        scope (exit) CloseWindow();

        while (!WindowShouldClose) {
            
            originX = GetScreenWidth()/2;
            originY = GetScreenHeight()/2;
            
            BeginDrawing();

            incrementVelocitiesAndThetas(&omega1, &omega2, &theta1, &theta2);

            draw();
            EndDrawing();
        }
    }


    void draw() {
        int x1 = to!(int)(l1 * sin(theta1));
        int y1 = to!(int)(l1 * cos(theta1));
        int x2 = x1 + to!(int)(l2 * sin(theta2));
        int y2 = y1 + to!(int)(l2 * cos(theta2));

        if (fabs(l2 * sin(theta2)) % 1 < 0.001) {
            breadcrumbs ~= [x2, y2, 1];
            byteStream ~= cast(ubyte)(fabs((omega1*omega2*theta1*theta2)%255));
            if (byteStream.length == 32) {
                // Pauses the simulation indefinitely.
                dt = 0;
                writeln(toHex(byteStream));
            }
        }

        else if (fabs(l2 * sin(theta2)) % 1 < 0.01) {
            breadcrumbs ~= [x2, y2, 0];
        }
        

        ClearBackground(Colors.BLACK);
        DrawLineV(Vector2(originX, originY), Vector2(originX+x1, originY+y1), Colors.WHITE);
        DrawLineV(Vector2(originX+x1, originY+y1), Vector2(originX+x2, originY+y2), Colors.WHITE);
        DrawCircle(originX+x1, originY+y1, 10, Colors.RED);
        DrawCircle(originX+x2, originY+y2, 10, Colors.RED);

        foreach (arr; breadcrumbs) {
            Color color;
            if (arr[2] == 0) {
                color = Colors.WHITE;
            } else {
                color = Colors.RED;
            }
            DrawCircle(arr[0]+originX, arr[1]+originY, 2, color);
        }
    }
}
