module double_pendulum;

import raylib;

import std.math.trigonometry;
import std.conv;
import std.stdio;
import std.math;
import std.math.constants;
import std.format;

import hash_components;
import pure_implementation;

class DoublePendulum {
    private:
    double omega1;
    double omega2;

    double theta1;
    double theta2;

    double l1 = 200;
    double l2 = 200;

    int[][] breadcrumbs;

    ubyte[] byteStream;

    string hash;
    Color primary;

    public:
    this(string input) {
        setSartingVariables(input, &omega1, &omega2, &theta1, &theta2);
        this.hash = doublePendulumHash(input);
        writeln(to!int(hash[0..2], 16));
        primary = Color(to!ubyte(hash[0..2], 16), to!ubyte(hash[2..4], 16), to!ubyte(hash[4..6], 16), 255);
    }

    void draw(int centerX, int centerY) {
        int x1 = to!(int)(l1 * sin(theta1));
        int y1 = to!(int)(l1 * cos(theta1));
        int x2 = x1 + to!(int)(l2 * sin(theta2));
        int y2 = y1 + to!(int)(l2 * cos(theta2));

        if (fabs(l2 * sin(theta2)) % 1 < 0.001) {
            breadcrumbs ~= [x2, y2, 1];
            byteStream ~= cast(ubyte)(fabs((omega1*omega2*theta1*theta2)%255));
            if (byteStream.length == 32) {
                string output = toHex(byteStream);
                writeln(output);
                assert(hash == output);
            }
        }

        else if (fabs(l2 * sin(theta2)) % 1 < 0.01) {
            //breadcrumbs ~= [x2, y2, 0];
        }
        

        ClearBackground(Colors.BLACK);
        DrawLineV(Vector2(centerX, centerY), Vector2(centerX+x1, centerY+y1), Colors.WHITE);
        DrawLineV(Vector2(centerX+x1, centerY+y1), Vector2(centerX+x2, centerY+y2), Colors.WHITE);
        DrawCircle(centerX+x1, centerY+y1, 10, primary);
        DrawCircle(centerX+x2, centerY+y2, 10, primary);

        foreach (arr; breadcrumbs) {
            Color color;
            if (arr[2] == 0) {
                color = Colors.WHITE;
            } else {
                color = primary;
            }
            DrawCircle(arr[0]+centerX, arr[1]+centerY, 2, color);
        }

        incrementVelocitiesAndThetas(&omega1, &omega2, &theta1, &theta2);
    }
}
