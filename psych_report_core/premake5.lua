workspace "PsychReportWorkspace"
    architecture "x86_64"
    configurations { "Release" }
    targetdir "build"

    project "main"
        kind "ConsoleApp"
        language "C"

        targetdir "build"
        objdir "build/obj"

        files {
            "src/main.c",
            "src/psych_report_core.c"
        }

        includedirs {
            "thirdparty/",
            "thirdparty/whisper.cpp/include",
            "thirdparty/whisper.cpp/ggml/include",
            "thirdparty/llama.cpp/include",
            "thirdparty/llama.cpp/ggml/include",
            "."
        }

        defines {
            "LLAMA_SHARED"
        }

        libdirs {
            "build"
        }

        links {
            "avformat",
            "avcodec",
            "avutil",
            "swresample",
            "ggml",
            "ggml-base",
            "ggml-cpu",
            "whisper",
            "llama",
            "ggml-vulkan"
        }

        filter "system:linux"
            links {
                "stdc++"
            }

            linkoptions {
                "-Wl,-rpath,'$$ORIGIN'",
                "-Wl,-z,origin"
            }

            prebuildcommands {
                "{MKDIR} build",
                "cd thirdparty/whisper.cpp && cmake -B build -DWHISPER_BUILD_TESTS=0 -DWHISPER_BUILD_EXAMPLES=0 -DWHISPER_BUILD_SERVER=0 -DGGML_VULKAN=1",
                "cd thirdparty/whisper.cpp && cmake --build build -j --config Release",
                "cp -P thirdparty/whisper.cpp/build/src/libwhisper.so* build/",

                "cd thirdparty/llama.cpp && cmake -B build -DLLAMA_BUILD_COMMON=0 -DGGML_VULKAN=1",
                "cd thirdparty/llama.cpp && cmake --build build -j --config Release",
                "cp -R thirdparty/llama.cpp/build/bin/* build/"
            }

        filter "system:windows"
            defines {
                "_CRT_SECURE_NO_WARNINGS"
            }

            prebuildcommands {
                "{MKDIR} build",

                -- Build whisper.cpp
                "cmake -B thirdparty/whisper.cpp/build -S thirdparty/whisper.cpp -DWHISPER_BUILD_TESTS=0 -DWHISPER_BUILD_EXAMPLES=0 -DWHISPER_BUILD_SERVER=0 -DGGML_VULKAN=1",
                "cmake --build thirdparty/whisper.cpp/build --config Release",
                "cmd /c copy /Y thirdparty\\whisper.cpp\\build\\src\\Release\\*.dll build\\",
                "cmd /c copy /Y thirdparty\\whisper.cpp\\build\\src\\Release\\*.lib build\\",

                -- Build llama.cpp
                "cmake -B thirdparty/llama.cpp/build -S thirdparty/llama.cpp -DLLAMA_BUILD_COMMON=0 -DGGML_VULKAN=1",
                "cmake --build thirdparty/llama.cpp/build --config Release",
                "cmd /c copy /Y thirdparty\\llama.cpp\\build\\bin\\Release\\* build\\"
            }

        filter {}
