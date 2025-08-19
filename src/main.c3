module novaboard;
import std::io;

import nk;
import raylib5::rl;
import novaboard::raylib_nk;

import std::math @public, std::math::easing;
import std::collections::tuple;
import std::collections::map;
import std::hash::fnv32a;

const FONT = $embed("../resources/Ubuntu-R.ttf");
const isz TILE_SIZE = 512;

alias Tile = Tuple{isz, isz};

fn uint Tile.hash(&self)
{
    return fnv32a::hash(
        @as_char_view(self)
    );
}

fn bool Tile.equals(&self, Tile other) @operator(==)
{
    return self.first == other.first && self.second == other.second;
}

fn int main(String[] args)
{
    rl::setConfigFlags(rl::FLAG_WINDOW_RESIZABLE);
    rl::initWindow(640, 480, "Novaboard");
    rl::setTargetFPS(120);
    defer rl::closeWindow();

    Font fnt = rl::loadFontFromMemory(".ttf", FONT.ptr, FONT.len, 32, null, 0);
    rl::setTextureFilter(fnt.texture, TextureFilter.BILINEAR);

    int font_size = 18;
    nk::Context *ctx = raylib_nk::init_nuklear_ex(fnt, font_size);
    defer raylib_nk::unload_nuklear(ctx);

    Camera2D camera;
    camera.target = {0, 0};
    camera.offset = {(float) math::floor(640 / 2), (float) math::floor(480 / 2)};
    camera.rotation = 0;
    camera.zoom = 1.0f;

    float target_zoom = 1.0f;

    Tile last_tile;
    RenderTexture2D *last;

    HashMap{Tile, rl::RenderTexture2D} tiles;

    while (!rl::windowShouldClose()) {
        int width = rl::getScreenWidth();
        int height = rl::getScreenHeight();
        Vector2 mouse = rl::getMousePosition();
        Vector2 mouse_world = rl::getScreenToWorld2D(mouse, camera);

        raylib_nk::update_nuklear(ctx);

        if (rl::isMouseButtonDown(rl::MouseButton.MIDDLE)) {
            Vector2 delta = rl::getMouseDelta();
            delta = rl::vector2Scale(delta, -1.0f/camera.zoom);
            camera.target = rl::vector2Add(camera.target, delta);
        } else if (rl::isMouseButtonDown(rl::MouseButton.LEFT)) {
            isz tile_x = (isz) math::floor(mouse_world.x / TILE_SIZE);
            isz tile_y = (isz) math::floor(mouse_world.y / TILE_SIZE);
            isz local_x = (isz) math::floor(mouse_world.x % TILE_SIZE);
            isz local_y = (isz) math::floor(mouse_world.y % TILE_SIZE);
            if (local_x < 0) local_x += TILE_SIZE;
            if (local_y < 0) local_y += TILE_SIZE;
            Tile current = {tile_x, tile_y};

            rl::RenderTexture2D *img;

            if (current == last_tile && last != null) {
                img = last;
            } else if (try img2 = tiles.get_ref(current)) {
                img = img2;
            } else {
                tiles[current] = rl::loadRenderTexture(TILE_SIZE, TILE_SIZE);
                img = tiles.get_ref(current)!!;
            }

            rl::beginTextureMode(*img);
            rl::drawCircle((int) local_x, (int) local_y, 3, rl::WHITE);
            rl::endTextureMode();
        }

        float wheel = rl::getMouseWheelMove();
        if (wheel != 0) {
            Vector2 mouseWorldPos = rl::getScreenToWorld2D(rl::getMousePosition(), camera);
            camera.offset = rl::getMousePosition();
            camera.target = mouseWorldPos;

            target_zoom = math::clamp(camera.zoom + wheel * 0.1f, 0.077f, 2.0f);
        }

        camera.zoom = math::lerp(camera.zoom, target_zoom, 0.25f);

        Vector2 top_left = rl::getScreenToWorld2D({0, 0}, camera);
        Vector2 bottom_right = rl::getScreenToWorld2D({width, height}, camera);

        isz min_tx = (isz) math::floor(top_left.x / TILE_SIZE) - 1;
        isz min_ty = (isz) math::floor(top_left.y / TILE_SIZE) - 1;
        isz max_tx = (isz) math::floor(bottom_right.x / TILE_SIZE) + 1;
        isz max_ty = (isz) math::floor(bottom_right.y / TILE_SIZE) + 1;

        rl::beginDrawing();
        rl::clearBackground({0x16, 0x16, 0x16, 0xFF});

        raylib_nk::draw_nuklear(ctx);
        rl::beginMode2D(camera);

        for (isz tx = min_tx; tx < max_tx; tx++) {
            for (isz ty = min_ty; ty < max_ty; ty++) {
                if (try rl::RenderTexture2D *tile = tiles.get_ref({tx, ty})) {

                    rl::Rectangle src = {0, 0, TILE_SIZE, -TILE_SIZE};
                    rl::Rectangle dst = {(float) tx * TILE_SIZE, (float) ty * TILE_SIZE, TILE_SIZE, TILE_SIZE};

                    rl::drawTexturePro(tile.texture, src, dst, {0, 0}, 0.0, rl::WHITE);
                }
            }
        }
        rl::endMode2D();
        rl::endDrawing();
    }
	return 0;
}
