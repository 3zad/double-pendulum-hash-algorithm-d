module collisiontest;

import std.stdio;
import std.conv;

import hash_components;

char[] charSet = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','!','"','#','$','%','&','\'','(',')','*','+',',','-','.','/',':',';','<','=','>','?','@','[','\\',']','^','_','`','{','|','}','~'];

void collisionTest() {
    string input;
    double o1, o2, t1, t2;

    string[string] datastore;

    int index = 0;
    int tempIndex;
    string pendulumVariableKey;
    while (true) {
        input = "";
        tempIndex = index;
        while (true) {
            input ~= charSet[tempIndex%charSet.length];
            tempIndex /= charSet.length;
            if (tempIndex < 1) {
                break;
            }
        }
        index++;

        if (index < charSet.length*charSet.length*charSet.length*charSet.length) {
            continue;
        }

        setSartingVariables(input, &o1, &o2, &t1, &t2);
        pendulumVariableKey = to!(string)(o1) ~ to!(string)(o2) ~ to!(string)(t1) ~ to!(string)(t2);
        if (pendulumVariableKey in datastore) {
            writeln("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            write("! COLLISION FOUND BETWEEN STRINGS ");
            writeln(input ~ " AND " ~ datastore[pendulumVariableKey]);
            writeln("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            //break;
        }
        datastore[pendulumVariableKey] = input;
    }
}