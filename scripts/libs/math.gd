class_name Math

## Computes greatest common divisor of a and b
static func gcd(a: int, b: int):
    while a != 0 and b != 0:
        if a < b:
            b %= a
        else:
            a %= b
    return max(a, b)
    