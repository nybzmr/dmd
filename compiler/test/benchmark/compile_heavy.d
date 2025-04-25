import std.stdio;
import std.conv;

enum size_t N = 100_000;

static foreach (i; 0 .. N) {
    mixin("enum Value" ~ to!string(i) ~ " = " ~ to!string(i) ~ ";");
}

void main() {
    writeln("Generated ", N, " compile-time enums.");
}
