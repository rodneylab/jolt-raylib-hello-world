#include "game.h"

#include "constants.h"

#include <fmt/core.h>
#include <imgui.h>
#include <raylib.h>

#include <queue>
#include <string>

void draw_scene(const Camera &camera,
                const Vector3 &ball_position,
                const Color &ball_colour,
                const Font &font)
{
    BeginMode3D(camera);
    DrawSphere(ball_position, constants::kBallRadius, ball_colour);
    DrawGrid(constants::kGridSlices, constants::kGridSpacing);
    EndMode3D();
    const float kDefaultFontSize{10.F};
    DrawTextEx(font,
               "Press F9 for ImGui debug mode",
               Vector2{constants::kTextPositionX, constants::kTextPositionY},
               static_cast<float>(constants::kTextFontSize),
               static_cast<float>(constants::kTextFontSize) / kDefaultFontSize,
               DARKGRAY);
    DrawFPS(constants::kFPSPositionX, constants::kFPSPositionY);
}

void Game_Update(std::queue<int> *key_queue, bool *debug_menu)
{
    for (; !key_queue->empty(); key_queue->pop())
    {
        const int key{key_queue->front()};
        if (key == 0)
        {
            continue;
        }
        if (key == KEY_F9)
        {
            *(debug_menu) = !(*debug_menu);
        }
    }
}

void Game_DrawDebug(int &selected_sphere_colour)
{
    ImGui::Begin("Dev Panel");

    ImGui::Text("%s", // NOLINT [cppcoreguidelines-pro-type-vararg]
                fmt::format("FPS: {}", GetFPS()).c_str());

    if (ImGui::TreeNode("Sphere colour"))
    {
        int index{0};
        for (const std::string &colour : constants::kSphereColourLabels)
        {
            ImGui::RadioButton(colour.c_str(), &selected_sphere_colour, index);
            ++index;
        }
    }
    ImGui::End();
}
