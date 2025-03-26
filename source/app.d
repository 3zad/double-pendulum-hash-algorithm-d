import raylib;

import std.math.trigonometry;
import std.conv;
import std.stdio;
import std.math;
import std.math.constants;
import std.format;

void main() {
    string toHash = "password123!";

    ubyte[] byteArr;
    foreach (c; toHash) {
        byteArr ~= to!(ubyte)(c);
    }

    while (byteArr.length % 16 != 0) {
        // Collision prone... maybe... fix later
        byteArr ~= 0xFF;
    }

    double omega1 = 0;
    double omega2 = 0;
    double theta1 = 0;
    double theta2 = 0;

    for (int i = 0; i < byteArr.length; i +=16) {
        omega1 += to!(double)(4*byteArr[i]+3*byteArr[i+1]+2*byteArr[i+2]+byteArr[i+3])/(1024*4*3*2);
        omega2 += to!(double)(4*byteArr[i+4]+3*byteArr[i+5]+2*byteArr[i+6]+byteArr[i+7])/(1024*4*3*2);
        theta1 += to!(double)(4*byteArr[i+8]+3*byteArr[i+9]+2*byteArr[i+10]+byteArr[i+11]);
        theta2 += to!(double)(4*byteArr[i+12]+3*byteArr[i+13]+2*byteArr[i+14]+byteArr[i+15]);
    }

    omega1 /= (byteArr.length/16);
    omega2 /= (byteArr.length/16);
    theta1 /= (byteArr.length/16);
    theta2 /= (byteArr.length/16);

    auto d = new DoublePendulum(omega1, omega2, 200, 200, 10, 10, theta1, theta2, 100);
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

    double t1;
    double t2;

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
        this.t1 = theta1;
        this.t2 = theta2;
        this.g = gravity;
        this.dt = 0.0100001;

        this.breadcrumbs = [];
        this.byteStream = [];
    }

    void run() {
        SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
        SetConfigFlags(ConfigFlags.FLAG_WINDOW_ALWAYS_RUN);
        InitWindow(512, 512, "Double pendulum simulation");
        // High FPS to allow smooth and accurate simulations (possible to set dt smaller)
        SetTargetFPS(10000000);

        scope (exit) CloseWindow();

        while (!WindowShouldClose) {
            
            originX = GetScreenWidth()/2;
            originY = GetScreenHeight()/2;
            
            BeginDrawing();

            // RK4 formula
            double k1_omega1 = dt * f1(t1, t2, omega1, omega2);
            double k1_omega2 = dt * f2(t1, t2, omega1, omega2);

            double k2_omega1 = dt * f1(t1 + k1_omega1 / 2, t2 + k1_omega2 / 2,
                    omega1 + k1_omega1 / 2, omega2 + k1_omega2 / 2);
            double k2_omega2 = dt * f2(t1 + k1_omega1 / 2, t2 + k1_omega2 / 2,
                    omega1 + k1_omega1 / 2, omega2 + k1_omega2 / 2);

            double k3_omega1 = dt * f1(t1 + k2_omega1 / 2, t2 + k2_omega2 / 2,
                    omega1 + k2_omega1 / 2, omega2 + k2_omega2 / 2);
            double k3_omega2 = dt * f2(t1 + k2_omega1 / 2, t2 + k2_omega2 / 2,
                    omega1 + k2_omega1 / 2, omega2 + k2_omega2 / 2);

            double k4_omega1 = dt * f1(t1 + k3_omega1, t2 + k3_omega2,
                    omega1 + k3_omega1, omega2 + k3_omega2);
            double k4_omega2 = dt * f2(t1 + k3_omega1, t2 + k3_omega2,
                    omega1 + k3_omega1, omega2 + k3_omega2);

            omega1 += (k1_omega1 + 2 * k2_omega1 + 2 * k3_omega1 + k4_omega1) / 6;
            omega2 += (k1_omega2 + 2 * k2_omega2 + 2 * k3_omega2 + k4_omega2) / 6;

            t1 += omega1 * dt;
            t2 += omega2 * dt;

            draw();
            EndDrawing();
        }
    }

    // Helper function for RK4
    double f1(double t1, double t2, double w1, double w2) {
        double num1 = -g * (2 * m1 + m2) * sin(t1);
        double num2 = -m2 * g * sin(t1 - 2 * t2);
        double num3 = -2 * sin(t1 - t2) * m2;
        double num4 = w2 * w2 * l2 + w1 * w1 * l1 * cos(t1 - t2);
        double den = l1 * (2 * m1 + m2 - m2 * cos(2 * t1 - 2 * t2));
        return (num1 + num2 + num3 * num4) / den;
    }

    // Helper function for RK4
    double f2(double t1, double t2, double w1, double w2) {
        double num1 = 2 * sin(t1 - t2);
        double num2 = (w1 * w1 * l1 * (m1 + m2) + g * (m1 + m2) * cos(t1)
                + w2 * w2 * l2 * m2 * cos(t1 - t2));
        double den = l2 * (2 * m1 + m2 - m2 * cos(2 * t1 - 2 * t2));
        return (num1 * num2) / den;
    }

    void draw() {
        int x1 = originX + to!(int)(l1 * sin(t1));
        int y1 = originY + to!(int)(l1 * cos(t1));
        int x2 = x1 + to!(int)(l2 * sin(t2));
        int y2 = y1 + to!(int)(l2 * cos(t2));

        if (fabs(l2 * sin(t2)) % 1 < 0.001) {
            breadcrumbs ~= [x2-originX, y2-originY, 1];
            byteStream ~= cast(ubyte)(fabs((omega1*omega2*t1*t2)%255));
            if (byteStream.length == 32) {
                dt = 0;
                writeln(toHex(byteStream));
            }
        }

        else if (fabs(l2 * sin(t2)) % 1 < 0.01) {
            breadcrumbs ~= [x2-originX, y2-originY, 0];
        }
        

        ClearBackground(Colors.BLACK);
        DrawLineV(Vector2(originX, originY), Vector2(x1, y1), Colors.WHITE);
        DrawLineV(Vector2(x1, y1), Vector2(x2, y2), Colors.WHITE);
        DrawCircle(x1, y1, 10, Colors.RED);
        DrawCircle(x2, y2, 10, Colors.RED);

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

    string toHex(ubyte[] arr) {
        string hexString = "";
        
        foreach (ubyte b; arr) {
            hexString ~= to!string(format("%02X", b));
        }
        
        return hexString;
    }
}
