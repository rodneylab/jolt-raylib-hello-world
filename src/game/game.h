#ifndef SRC_GAME_GAME_H
#define SRC_GAME_GAME_H

#include <raylib.h>

#include <queue>

void draw_scene(const Camera &camera,
                const Vector3 &ball_position,
                const Color &ball_colour,
                const Font &font);
void Game_Update(std::queue<int> *key_queue, bool *debug_menu);
void Game_DrawDebug(int &selected_sphere_colour);

#endif
