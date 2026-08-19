#define NOB_IMPLEMENTATION
#include "nob.h"

#define BUILD_FOLDER "build/"
#define SRC_FOLDER   "src/"
#define VENDOR_FOLDER "vendor/"

bool build_whisper() {
    bool result = true;
    nob_set_current_dir(VENDOR_FOLDER"whisper.cpp");
    Nob_Cmd cmd = {0};
    nob_cmd_append(&cmd, "cmake", "-B", "build");
    nob_cmd_append(&cmd, "-DWHISPER_BUILD_TESTS=0", "-DWHISPER_BUILD_EXAMPLES=0", "-DWHISPER_BUILD_SERVER=0");
    //    nob_cmd_append(&cmd, "-DGGML_VULKAN=1", "DGGML_AVX512=OFF");
    if (!nob_cmd_run(&cmd)) nob_return_defer(false);
    nob_cmd_append(&cmd, "cmake", "--build", "build", "-j", "--config", "Release");
    if (!nob_cmd_run(&cmd)) nob_return_defer(false);
    nob_set_current_dir("../..");
    nob_copy_file(VENDOR_FOLDER"whisper.cpp/build/src/libwhisper.so", BUILD_FOLDER"libwhisper.so");
    nob_copy_file(VENDOR_FOLDER"whisper.cpp/build/src/libwhisper.so.1", BUILD_FOLDER"libwhisper.so.1");
    nob_copy_file(VENDOR_FOLDER"whisper.cpp/build/src/libwhisper.so.1.8.4", BUILD_FOLDER"libwhisper.so.1.8.4");

    defer:
        cmd_free(cmd);
        return result;
}

bool build_llama() {
    bool result = true;
    nob_set_current_dir(VENDOR_FOLDER"llama.cpp");
    Nob_Cmd cmd = {0};
    nob_cmd_append(&cmd, "cmake", "-B", "build");
    nob_cmd_append(&cmd, "-DLLAMA_BUILD_COMMON=0");
    if (!nob_cmd_run(&cmd)) nob_return_defer(false);
    nob_cmd_append(&cmd, "cmake", "--build", "build", "-j", "--config", "Release");
    if (!nob_cmd_run(&cmd)) nob_return_defer(false);

    nob_set_current_dir("../..");
    Nob_File_Paths children = {0};
    if (!nob_read_entire_dir(VENDOR_FOLDER"llama.cpp/build/bin", &children)) nob_return_defer(false);
    for (size_t i = 0; i < children.count; ++i) {
        if (strcmp(children.items[i], ".") == 0) continue;
        if (strcmp(children.items[i], "..") == 0) continue;

        if (!nob_copy_file(nob_temp_sprintf(VENDOR_FOLDER"llama.cpp/build/bin/%s", children.items[i]), nob_temp_sprintf(BUILD_FOLDER"%s", children.items[i]))) nob_return_defer(false);
    }

    defer:
        cmd_free(cmd);
        return result;
}

bool build_deps() {
    return build_whisper() && build_llama();
}

int main(int argc, char **argv) {
    NOB_GO_REBUILD_URSELF(argc, argv);
    if (!nob_mkdir_if_not_exists(BUILD_FOLDER)) return 1;
    build_deps();
    Nob_Cmd cmd = {0};
    nob_cc(&cmd);
    nob_cc_flags(&cmd);
    nob_cmd_append(&cmd, "-Ivendor/whisper.cpp/include");
    nob_cmd_append(&cmd, "-Ivendor/whisper.cpp/ggml/include");
    nob_cmd_append(&cmd, "-Ivendor/llama.cpp/include");
    nob_cmd_append(&cmd, "-Ivendor/llama.cpp/ggml/include");
    nob_cmd_append(&cmd, "-I./");
    nob_cmd_append(&cmd, "-lavformat");
    nob_cmd_append(&cmd, "-lavcodec");
    nob_cmd_append(&cmd, "-lavutil");
    nob_cmd_append(&cmd, "-lswresample");
    nob_cmd_append(&cmd, "-Lbuild");
    nob_cmd_append(&cmd, "-Wl,-rpath,$ORIGIN");
    nob_cmd_append(&cmd, "-Wl,-z,origin");
    nob_cmd_append(&cmd, "-lggml");
    nob_cmd_append(&cmd, "-lggml-base");
    nob_cmd_append(&cmd, "-lggml-cpu");
//    nob_cmd_append(&cmd, "-lggml-vulkan");
    nob_cmd_append(&cmd, "-lwhisper");
    nob_cmd_append(&cmd, "-lllama");
    nob_cmd_append(&cmd, "-DLLAMA_SHARED");
    nob_cmd_append(&cmd, "-lstdc++");
    nob_cc_output(&cmd, BUILD_FOLDER "main");
    nob_cc_inputs(&cmd, SRC_FOLDER "main.c");
    nob_cc_inputs(&cmd, SRC_FOLDER "psych_report_core.c");
    if (!nob_cmd_run(&cmd)) return 1;

    cmd_free(cmd);
    return 0;
}
