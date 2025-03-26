module hash_components;

import std.math;
import std.conv;
import std.format;

public string toHex(ubyte[] arr) {
        string hexString = "";
        
        foreach (ubyte b; arr) {
            hexString ~= to!string(format("%02X", b));
        }
        
        return hexString;
    }

public void incrementVelocitiesAndThetas(double* omega1, double* omega2, double* theta1, double* theta2) {
    // RK4 formula
    double k1_omega1 = 0.01 * f1((*theta1), (*theta2), (*omega1), (*omega2));
    double k1_omega2 = 0.01 * f2((*theta1), (*theta2), (*omega1), (*omega2));

    double k2_omega1 = 0.01 * f1((*theta1) + k1_omega1 / 2, (*theta2) + k1_omega2 / 2,
            (*omega1) + k1_omega1 / 2, (*omega2) + k1_omega2 / 2);
    double k2_omega2 = 0.01 * f2((*theta1) + k1_omega1 / 2, (*theta2) + k1_omega2 / 2,
            (*omega1) + k1_omega1 / 2, (*omega2) + k1_omega2 / 2);

    double k3_omega1 = 0.01 * f1((*theta1) + k2_omega1 / 2, (*theta2) + k2_omega2 / 2,
            (*omega1) + k2_omega1 / 2, (*omega2) + k2_omega2 / 2);
    double k3_omega2 = 0.01 * f2((*theta1) + k2_omega1 / 2, (*theta2) + k2_omega2 / 2,
            (*omega1) + k2_omega1 / 2, (*omega2) + k2_omega2 / 2);

    double k4_omega1 = 0.01 * f1((*theta1) + k3_omega1, (*theta2) + k3_omega2,
            (*omega1) + k3_omega1, (*omega2) + k3_omega2);
    double k4_omega2 = 0.01 * f2((*theta1) + k3_omega1, (*theta2) + k3_omega2,
            (*omega1) + k3_omega1, (*omega2) + k3_omega2);

    (*omega1) += (k1_omega1 + 2 * k2_omega1 + 2 * k3_omega1 + k4_omega1) / 6;
    (*omega2) += (k1_omega2 + 2 * k2_omega2 + 2 * k3_omega2 + k4_omega2) / 6;

    (*theta1) += (*omega1) * 0.01;
    (*theta2) += (*omega2) * 0.01;
}

// Helper function for RK4
private double f1(double theta1, double theta2, double w1, double w2) {
    double num1 = -9.81 * (2 * 10 + 10) * sin(theta1);
    double num2 = -10 * 9.81 * sin(theta1 - 2 * theta2);
    double num3 = -2 * sin(theta1 - theta2) * 10;
    double num4 = w2 * w2 * 200 + w1 * w1 * 200 * cos(theta1 - theta2);
    double den = 200 * (2 * 10 + 10 - 10 * cos(2 * theta1 - 2 * theta2));
    return (num1 + num2 + num3 * num4) / den;
}

// Helper function for RK4
private double f2(double theta1, double theta2, double w1, double w2) {
    double num1 = 2 * sin(theta1 - theta2);
    double num2 = (w1 * w1 * 200 * (10 + 10) + 9.81 * (10 + 10) * cos(theta1)
            + w2 * w2 * 200 * 10 * cos(theta1 - theta2));
    double den = 200 * (2 * 10 + 10 - 10 * cos(2 * theta1 - 2 * theta2));
    return (num1 * num2) / den;
}