#version 130

in vec2 Texcoord;

out vec4 outColor;

uniform sampler2D distanceField;

void main() {
    float distance = texture(distanceField, Texcoord).a;
    float smoothWidth = fwidth(distance);
    float alpha = smoothstep(0.5 - smoothWidth, 0.5 + smoothWidth, distance);
    outColor = vec4(1.0, 1.0, 1.0, alpha);
}
