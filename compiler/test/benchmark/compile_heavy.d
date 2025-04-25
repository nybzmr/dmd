/**
 * @file compile_heavy.d
 * @brief Generates a large number of enums at compile time to stress the D compiler.
 *
 * Adjust the `N` parameter to tune compile duration.
 *
 * Usage:
 *   dmd -O -release -inline -boundscheck=off compiler/test/compile_heavy.d
 */
import std.stdio;
import std.conv;

/** Number of enums to generate (adjust for desired compile time) */
enum size_t N = 100_000;

static foreach (i; 0 .. N) {
    enum mixin("Value" ~ to!string(i)) = i;
}

void main() {
    writeln("Generated ", N, " compile-time enums.");
}
