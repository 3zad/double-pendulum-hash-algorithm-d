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
    ubyte[] byteArr;
    foreach (c; input) {
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

