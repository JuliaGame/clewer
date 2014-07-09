#version 130

uniform vec2 pos;

in vec2 position;

void main() {
    mat2 projection = mat2(
        vec2(3.0/4.0, 0.0),
        vec2(0.0, 1.0)
    );
    gl_Position = vec4(projection * (pos + position), 0.0, 1.0);
}
