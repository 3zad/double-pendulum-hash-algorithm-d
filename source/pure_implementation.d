module pure_implementation;

import std.math.trigonometry;
import std.conv;
import std.stdio;
import std.math;
import std.math.constants;
import std.format;

import hash_components;
import std.datetime.stopwatch;

string doublePendulumHash(string input) {
    double omega1, omega2, theta1, theta2;
    
    setSartingVariables(input, &omega1, &omega2, &theta1, &theta2);

    ubyte[] byteStream;

    while (true) {
        incrementVelocitiesAndThetas(&omega1, &omega2, &theta1, &theta2);

        if (fabs(200 * sin(theta2)) % 1 < 0.001) {
            byteStream ~= cast(ubyte)(fabs((omega1*omega2*theta1*theta2)%255));
            if (byteStream.length == 32) {
                return toHex(byteStream);
            }
        }
    }
}

void benchmark() {
    auto sw = StopWatch(AutoStart.no);
    
    double iterations = 100;
    
    writeln("Benchmark starting...");
    sw.start();

    for (int i = 0; i < iterations; i++) {
        doublePendulumHash(to!string(i));
    }

    sw.stop();
    writeln("Benchmark Ending...");

    long msecs = sw.peek.total!"msecs";

    writeln("Seconds taken for " ~ to!(string)(iterations) ~ " iterations: " ~ to!(string)(to!(double)(msecs)/1000));
    writeln("Average time per hash (in miliseconds): " ~ to!(string)(msecs/iterations)); 
}

