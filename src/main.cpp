#include "constants.h"
#include "game/game.h"
#include "physics.h"

#include <imgui.h>
#include <raylib.h>
#include <rlImGui.h>
#include <spdlog/spdlog.h>

#include <array>
#include <cstddef>
#include <cstdint>
#include <queue>
#include <string>

void setup_camera(Camera3D &camera)
{
    camera.position = Vector3{constants::kCameraPositionX,
                              constants::kCameraPositionY,
                              constants::kCameraPositionZ};
    constexpr float kCameraTargetX{0.F};
    camera.target = Vector3{kCameraTargetX, 0.F, 0.F};
    camera.up = Vector3{0.F, 1.F, 0.F};
    camera.fovy = constants::kCameraFovY;
    camera.projection = CAMERA_PERSPECTIVE;
}

int main(int /* argc */, char ** /* argv */)
{
    double tickTimer{0.0};
    std::queue<int> keyQueue{std::queue<int>()};
    bool debugMenu = false;
    const Vector2 windowSize{
        Vector2{constants::kWindowWidth, constants::kWindowHeight}};
    RenderTexture gameTexture;
    RenderTexture debugTexture;

    SetWindowState(FLAG_MSAA_4X_HINT);
    InitWindow(static_cast<int>(windowSize.x),
               static_cast<int>(windowSize.y),
               constants::kTitle.c_str());
    rlImGuiSetup(true);

    gameTexture = LoadRenderTexture((int)windowSize.x, (int)windowSize.y);
    constexpr float kDebugScaleUp{1.5F};
    debugTexture =
        LoadRenderTexture(static_cast<int>(windowSize.x / kDebugScaleUp),
                          static_cast<int>(windowSize.y / kDebugScaleUp));

    const Rectangle source_rectangle{0,
                                     -windowSize.y,
                                     windowSize.x,
                                     -windowSize.y};
    const Rectangle destination_rectangle{0,
                                          0,
                                          windowSize.x / kDebugScaleUp,
                                          windowSize.y / kDebugScaleUp};
    Camera3D camera{};
    setup_camera(camera);

    constexpr int kMillisecondsPerSecond{1000};
    constexpr float kBallInitialPositionY{10.F};
    Vector3 sphere_position{0.F, kBallInitialPositionY, 0.F};
    const Vector3 sphere_velocity{0.5F, 0.F, 0.F};
    const Font font{LoadFont(ASSETS_PATH "ibm-plex-mono-v19-latin-500.ttf")};
    int selected_sphere_colour{0};

    const Vector3 floor_position{0.F, -1.F, 0.F};
    const Vector3 floor_dimensions{5.F, 1.F, 5.F};

    spdlog::info("Creating Physics Engine");
    PhysicsEngine physics_engine{};

    spdlog::info("Initialising Physics Engine");
    physics_engine.initialise();

    spdlog::info("Creating floor");
    physics_engine.create_floor(floor_dimensions, floor_position);

    spdlog::info("Creating ball");
    physics_engine.create_ball(constants::kBallRadius,
                               sphere_position,
                               sphere_velocity);

    spdlog::info("Initiating Pre-simulation Optimisation");
    physics_engine.start_simulation();

    // We simulate the physics world in discrete time steps. 60 Hz is a good rate
    // to update the physics system.
    SetTargetFPS(constants::kTargetFramerate);

    spdlog::info("Starting Simulation");

    while (!WindowShouldClose())
    {
        const float frame_time{GetFrameTime()};
        if (GetTime() - tickTimer >
            static_cast<float>(kMillisecondsPerSecond) /
                static_cast<float>(constants::kTickrate) /
                static_cast<float>(kMillisecondsPerSecond))
        {
            tickTimer = GetTime();
            Game_Update(&keyQueue, &debugMenu);
        }

        keyQueue.push(GetKeyPressed());

        BeginDrawing();
        rlImGuiBegin();
        ClearBackground(DARKGRAY);

        if (debugMenu)
        {
            BeginTextureMode(gameTexture);
            ClearBackground(RAYWHITE);
            draw_scene(camera,
                       sphere_position,
                       constants::kSphereColours[static_cast<size_t>(
                           selected_sphere_colour)],
                       font);
            EndTextureMode();

            BeginTextureMode(debugTexture);
            DrawTexturePro(gameTexture.texture,
                           source_rectangle,
                           destination_rectangle,
                           {0, 0},
                           0.F,
                           RAYWHITE);
            EndTextureMode();

            Game_DrawDebug(selected_sphere_colour);

            ImGui::Begin(
                "Jolt raylib Hello World!",
                &debugMenu,
                static_cast<uint8_t>( // NOLINT [hicpp-signed-bitwise]
                    ImGuiWindowFlags_AlwaysAutoResize) |
                    static_cast<uint8_t>(ImGuiWindowFlags_NoResize) |
                    static_cast<uint8_t>(ImGuiWindowFlags_NoBackground));
            rlImGuiImageRenderTexture(&debugTexture);
            ImGui::End();
        }
        else
        {
            ClearBackground(RAYWHITE);
            draw_scene(camera,
                       sphere_position,
                       constants::kSphereColours[static_cast<size_t>(
                           selected_sphere_colour)],
                       font);
        }
        rlImGuiEnd();
        EndDrawing();

        // advance the physics engine one step and get the updated sphere_position
        physics_engine.update(frame_time, sphere_position);
    }
    spdlog::info("Preparing Physics Engine for Shutdown");
    physics_engine.cleanup();

    return 0;
}
