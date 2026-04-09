module hash_components;

import core.math : sin, cos;
import std.math.constants;
import std.conv;
import std.format;

public string toHex(ubyte[] arr) {
    string hexString = "";

    foreach (ubyte b; arr) {
            hexString ~= to!string(format("%02X", b));
    }

    return hexString;
}

public void setSartingVariables(string input, double* omega1, double* omega2, double* theta1, double* theta2) {
    ubyte[] byteArr;
    foreach (c; input) {
        byteArr ~= to!(ubyte)(c);
    }

    ulong originalLen = byteArr.length;
    byteArr ~= 0x80;
    while (byteArr.length % 16 != 8) {
        byteArr ~= 0x00;
    }
    for (int s = 56; s >= 0; s -= 8) {
        byteArr ~= cast(ubyte)((originalLen >> s) & 0xFF);
    }
 
    (*theta1) = PI_4;
    (*theta2) = -PI/3.0;
    (*omega1)  = 0.5;
    (*omega2)  = -0.3;

    ulong s0 = 0x6C62272E07BB0142UL;
    ulong s1 = 0x62B821756295C58DUL;
    ulong s2 = 0x9E3779B97F4A7C15UL;
    ulong s3 = 0xBF58476D1CE4E5B9UL;
 
    for (int i = 0; i < byteArr.length; i += 16) {
        ulong b0 = (cast(ulong)byteArr[i+0]  << 24) | (cast(ulong)byteArr[i+1]  << 16)
                 | (cast(ulong)byteArr[i+2]  <<  8) |  cast(ulong)byteArr[i+3];
        ulong b1 = (cast(ulong)byteArr[i+4]  << 24) | (cast(ulong)byteArr[i+5]  << 16)
                 | (cast(ulong)byteArr[i+6]  <<  8) |  cast(ulong)byteArr[i+7];
        ulong b2 = (cast(ulong)byteArr[i+8]  << 24) | (cast(ulong)byteArr[i+9]  << 16)
                 | (cast(ulong)byteArr[i+10] <<  8) |  cast(ulong)byteArr[i+11];
        ulong b3 = (cast(ulong)byteArr[i+12] << 24) | (cast(ulong)byteArr[i+13] << 16)
                 | (cast(ulong)byteArr[i+14] <<  8) |  cast(ulong)byteArr[i+15];
 
        s0 ^= b0; s0 = rotl(s0, 27); s0 *= 0x94D049BB133111EBUL; s0 ^= s1;
        s1 ^= b1; s1 = rotl(s1, 31); s1 *= 0xBF58476D1CE4E5B9UL; s1 ^= s2;
        s2 ^= b2; s2 = rotl(s2, 17); s2 *= 0x9E3779B97F4A7C15UL; s2 ^= s3;
        s3 ^= b3; s3 = rotl(s3, 23); s3 *= 0x6C62272E07BB0142UL; s3 ^= s0;
    }
 
    double norm = 1.0 / cast(double)(ulong.max);
    (*theta1) += (cast(double)s0 * norm - 0.5) * 2.0;
    (*theta2) += (cast(double)s1 * norm - 0.5) * 2.0;
    (*omega1)  = (cast(double)s2 * norm - 0.5) * 4.0;
    (*omega2)  = (cast(double)s3 * norm - 0.5) * 4.0;
}

private ulong rotl(ulong x, int k) {
    return (x << k) | (x >> (64 - k));
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

public void incrementVelocitiesAndThetas(double* omega1, double* omega2, double* theta1, double* theta2) {
    double dt = 0.01;
 
    double k1_t1 = dt * (*omega1);
    double k1_t2 = dt * (*omega2);
    double k1_w1 = dt * f1((*theta1), (*theta2), (*omega1), (*omega2));
    double k1_w2 = dt * f2((*theta1), (*theta2), (*omega1), (*omega2));
 
    double k2_t1 = dt * ((*omega1) + k1_w1 / 2);
    double k2_t2 = dt * ((*omega2) + k1_w2 / 2);
    double k2_w1 = dt * f1((*theta1) + k1_t1/2, (*theta2) + k1_t2/2,
                            (*omega1) + k1_w1/2, (*omega2) + k1_w2/2);
    double k2_w2 = dt * f2((*theta1) + k1_t1/2, (*theta2) + k1_t2/2,
                            (*omega1) + k1_w1/2, (*omega2) + k1_w2/2);
 
    double k3_t1 = dt * ((*omega1) + k2_w1 / 2);
    double k3_t2 = dt * ((*omega2) + k2_w2 / 2);
    double k3_w1 = dt * f1((*theta1) + k2_t1/2, (*theta2) + k2_t2/2,
                            (*omega1) + k2_w1/2, (*omega2) + k2_w2/2);
    double k3_w2 = dt * f2((*theta1) + k2_t1/2, (*theta2) + k2_t2/2,
                            (*omega1) + k2_w1/2, (*omega2) + k2_w2/2);
 
    double k4_t1 = dt * ((*omega1) + k3_w1);
    double k4_t2 = dt * ((*omega2) + k3_w2);
    double k4_w1 = dt * f1((*theta1) + k3_t1, (*theta2) + k3_t2,
                            (*omega1) + k3_w1, (*omega2) + k3_w2);
    double k4_w2 = dt * f2((*theta1) + k3_t1, (*theta2) + k3_t2,
                            (*omega1) + k3_w1, (*omega2) + k3_w2);
 
    (*theta1) += (k1_t1 + 2*k2_t1 + 2*k3_t1 + k4_t1) / 6;
    (*theta2) += (k1_t2 + 2*k2_t2 + 2*k3_t2 + k4_t2) / 6;
    (*omega1) += (k1_w1 + 2*k2_w1 + 2*k3_w1 + k4_w1) / 6;
    (*omega2) += (k1_w2 + 2*k2_w2 + 2*k3_w2 + k4_w2) / 6;
}

// Helper function for RK4
private double f1(double theta1, double theta2, double w1, double w2) {
    double delta = theta1 - theta2;
    double den = 2 - cos(2 * delta);
    double num1 = -9.81 * (2 * sin(theta1));
    double num2 = -sin(delta) * (2 * w2*w2 + w1*w1 * cos(delta));
    return (num1 + num2 * 2) / den;
}

// Helper function for RK4
private double f2(double theta1, double theta2, double w1, double w2) {
    double delta = theta1 - theta2;
    double den = 2 - cos(2 * delta);
    double num = 2 * sin(delta) * (2 * w1*w1 + 9.81 * cos(theta1) + w2*w2 * cos(delta));
    return num / den;
}