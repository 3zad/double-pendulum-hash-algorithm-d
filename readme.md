# Hashing algorithm using the chaotic nature of a double pendulum

**NB! This algorithm is a hobby project and not to be used for real security purposes!**

## Summary:
* The string to be hashed is parsed into 4 starting variables for the double pendulum:
    - Angular velocity 1
    - Angular velocity 2
    - Theta 1
    - Theta 2
* When the pendulum's lower arm's Y-position's decimal is below 0.001, both angular velocities and thetas are combined into one variable and recorded (this is marked with a red dot on-screen).
* The previous step repeats until a 256-bit string is produced.

## Benchmarks
This algorithm is quite slow. In fact, REALLY slow. Each hash takes on average 30 miliseconds. Good luck making a rainbow table for this one.

---

A picture of the completed process of hashing the string "password123!".

![alt text](password123!.png "picture of password123!")

Example inputs and outputs:
---
a - A41C15A1AEE938BB753D3AA25F71658D138AD80D7292F084FE0B15EEAB13AB0E

b - 6F0D6E56A52EEC250FAC37B211F2092785DB6E6ABCC850CE7022C552B60AEFCB

c - 09F44A0C8ECB6B15FDFB4E9B1AEA030F502AFE3F918ED15A382C2FCA9879E465


password123! - C1F5AE3A80B28808193B064955E8C023D18879A1202B118FFD16132F54FC9221

pasword123! - 1B66D874A77D033F973D18F2B54590E7BCC373BCAD16E4A4EF9632ED812AD9AF


The quick brown fox jumps over the lazy dog - 596F9889B1F9FAF2CF7AFAC0E0D6DB4A9011059EE9A19604B2873E9CF2203189

the quick brown fox jumps over the lazy dog - 4C4679B012E0257C358EB5F347BF5234183CBD764070F0B359119B9E16417CBF




## Mechanics of the pendulum

RK4 for accurate calculations and floating-point error reduction.

<img alt="pilt" src="rk4.jpg">

## Useage
```sh
dub run
```