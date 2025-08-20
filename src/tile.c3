module novaboard::tile;

import std::io;
import raylib5::rl;
import std::collections::tuple;
import std::collections::map;
import std::hash::fnv32a;
import std::math;

alias Tile = Tuple{isz, isz};

fn uint Tile.hash(&self)
{
    return fnv32a::hash(
        @as_char_view(*self)
    );
}

fn bool Tile.equals(&self, Tile other) @operator(==)
{
    return self.first == other.first && self.second == other.second;
}

fn Tile new(Vector2 world_pos, isz tile_size)
{
    return {
        (isz) math::floor(world_pos.x / tile_size),
        (isz) math::floor(world_pos.y / tile_size),
    };
}

fn RenderTexture2D *Tile.get_texture(self, HashMap{Tile, RenderTexture2D} *tiles, int tile_size)
{
    if (try render_texture = tiles.get_ref(self)) {
        return render_texture;
    }

    tiles.set(self, rl::loadRenderTexture(tile_size, tile_size));
    return tiles.get_ref(self)!!;
}

struct TileContext {
    Tile tile;
    Vector2 pos;
}

fn void connect_tiles(TileContext previous, TileContext current, isz tile_size)
{
    isz prev_x = (isz) math::floor(previous.pos.x % tile_size);
    isz prev_y = (isz) math::floor(previous.pos.y % tile_size);

    if (prev_x < 0) prev_x += tile_size;
    if (prev_y < 0) prev_y += tile_size;

    isz curr_x = (isz) math::floor(current.pos.x % tile_size);
    isz curr_y = (isz) math::floor(current.pos.y % tile_size);

    if (curr_x < 0) curr_x += tile_size;
    if (curr_y < 0) curr_y += tile_size;

    Vector2 diff = {previous.pos.x - current.pos.x,
        previous.pos.y - current.pos.y};

    Tile tile_diff = {previous.tile.first - current.tile.first,
        previous.tile.second - current.tile.second};


    switch (tile_diff) {
        case { 0,  1}: /* up    */
            prev_x += (isz) diff.x;
            prev_y += (isz) diff.y + tile_size;
            rl::drawLineEx({prev_x, prev_y}, {curr_x, curr_y}, 5, rl::WHITE);
        case {-1,  1}: /* right, up */
            prev_x += (isz) diff.x - tile_size;
            prev_y += (isz) diff.y + tile_size;
            rl::drawLineEx({prev_x, prev_y}, {curr_x, curr_y}, 5, rl::WHITE);
        case {-1,  0}: /* right */
            prev_x += (isz) diff.x - tile_size;
            prev_y += (isz) diff.y;
            rl::drawLineEx({prev_x, prev_y}, {curr_x, curr_y}, 5, rl::WHITE);
        case {-1, -1}: /* right, down */
            prev_x += (isz) diff.x - tile_size;
            prev_y += (isz) diff.y - tile_size;
            rl::drawLineEx({prev_x, prev_y}, {curr_x, curr_y}, 5, rl::WHITE);
        case { 0, -1}: /* down  */
            prev_x += (isz) diff.x;
            prev_y += (isz) diff.y - tile_size;
            rl::drawLineEx({prev_x, prev_y}, {curr_x, curr_y}, 5, rl::WHITE);
        case { 1, -1}: /* left, down */
            prev_x += (isz) diff.x + tile_size;
            prev_y += (isz) diff.y - tile_size;
            rl::drawLineEx({prev_x, prev_y}, {curr_x, curr_y}, 5, rl::WHITE);
        case { 1,  0}: /* left  */
            prev_x += (isz) diff.x + tile_size;
            prev_y += (isz) diff.y;
            rl::drawLineEx({prev_x, prev_y}, {curr_x, curr_y}, 5, rl::WHITE);
        case { 1,  1}: /* left, up */
            prev_x += (isz) diff.x + tile_size;
            prev_y += (isz) diff.y + tile_size;
            rl::drawLineEx({prev_x, prev_y}, {curr_x, curr_y}, 5, rl::WHITE);
        case { 0,  0}:
            rl::drawLineEx({prev_x, prev_y}, {curr_x, curr_y}, 5, rl::WHITE);
    }

    rl::drawCircle((int) curr_x, (int) curr_y, 2, rl::WHITE);
}
