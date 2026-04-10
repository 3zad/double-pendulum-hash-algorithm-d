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

    while (byteStream.length < 32) {
        incrementVelocitiesAndThetas(&omega1, &omega2, &theta1, &theta2);

        if (fabs(200 * sin(theta2)) % 1 < 0.001) {
            byteStream ~= (cast(ubyte*)&omega1)[0];
            byteStream ~= (cast(ubyte*)&omega2)[0];
            byteStream ~= (cast(ubyte*)&theta1)[0];
            byteStream ~= (cast(ubyte*)&theta2)[0];
        }
    }

    return toHex(byteStream[0..32]);
}

public ubyte[] extractHash(double omega1, double omega2, double theta1, double theta2, int steps = 512) {
    for (int i = 0; i < steps; i++) {
        incrementVelocitiesAndThetas(&omega1, &omega2, &theta1, &theta2);
    }

    ubyte[] result;
    result ~= (cast(ubyte*)&theta1)[0..8];
    result ~= (cast(ubyte*)&theta2)[0..8];
    result ~= (cast(ubyte*)&omega1)[0..8];
    result ~= (cast(ubyte*)&omega2)[0..8];
    return result;
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

