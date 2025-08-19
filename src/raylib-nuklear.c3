module novaboard::raylib_nk;

import nk;
import raylib5::rl;

extern fn nk::Context* init_nuklear(int fontSize) @extern("InitNuklear");
extern fn nk::Context* init_nuklear_ex(Font font, float fontSize) @extern("InitNuklearEx");
extern fn Font load_font_from_nuklear(int fontSize) @extern("LoadFontFromNuklear");
extern fn void update_nuklear(nk::Context *ctx) @extern("UpdateNuklear");
extern fn void update_nuklear_ex(nk::Context *ctx, float deltaTime) @extern("UpdateNuklearEx");
extern fn void draw_nuklear(nk::Context *ctx) @extern("DrawNuklear");
extern fn void unload_nuklear(nk::Context *ctx) @extern("UnloadNuklear");

extern fn nk::Color color_to_nuklear(rl::Color color) @extern("ColorToNuklear");
extern fn nk::Colorf color_to_nuklear_f(rl::Color color) @extern("ColorToNuklearF");
extern fn rl::Color color_from_nuklear(nk::Color color) @extern("ColorFromNuklear");
extern fn rl::Color color_from_nuklear_f(nk::Colorf color) @extern("ColorFromNuklearF");
extern fn rl::Rectangle rectangle_from_nuklear(nk::Context* ctx, nk::Rect rect) @extern("RectangleFromNuklear");
extern fn nk::Rect rectangle_to_nuklear(nk::Context* ctx, Rectangle rect) @extern("RectangleToNuklear");
extern fn nk::Image texture_to_nuklear(Texture tex) @extern("TextureToNuklear");
extern fn rl::Texture texture_from_nuklear(nk::Image img) @extern("TextureFromNuklear");
extern fn nk::Image load_nuklear_image(char* path) @extern("LoadNuklearImage");
extern fn void unload_nuklear_image(nk::Image img) @extern("UnloadNuklearImage");
extern fn void cleanup_nuklear_image(nk::Image img) @extern("CleanupNuklearImage");
extern fn void set_nuklear_scaling(nk::Context* ctx, float scaling) @extern("SetNuklearScaling");
extern fn float get_nuklear_scaling(nk::Context* ctx) @extern("GetNuklearScaling");
