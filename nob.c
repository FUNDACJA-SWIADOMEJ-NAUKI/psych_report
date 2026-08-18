#define NOB_IMPLEMENTATION
#include "nob.h"

#define BUILD_FOLDER "build/"
#define SRC_FOLDER   "src/"
#define VENDOR_FOLDER "vendor/"

int build_whisper() {    
    nob_set_current_dir(VENDOR_FOLDER"whisper.cpp");    
    Nob_Cmd cmd = {0};
    nob_cmd_append(&cmd, "cmake", "-B", "build");
    nob_cmd_append(&cmd, "-DWHISPER_BUILD_TESTS=0", "-DWHISPER_BUILD_EXAMPLES=0", "-DWHISPER_BUILD_SERVER=0");
    //    nob_cmd_append(&cmd, "-DGGML_VULKAN=1", "DGGML_AVX512=OFF");
    if (!nob_cmd_run(&cmd)) return 1;
    nob_cmd_append(&cmd, "cmake", "--build", "build", "-j", "--config", "Release");
    if (!nob_cmd_run(&cmd)) return 1;
    nob_set_current_dir("../..");
    nob_copy_file(VENDOR_FOLDER"whisper.cpp/build/src/libwhisper.so", BUILD_FOLDER"libwhisper.so");
    nob_copy_file(VENDOR_FOLDER"whisper.cpp/build/src/libwhisper.so.1", BUILD_FOLDER"libwhisper.so.1");
    nob_copy_file(VENDOR_FOLDER"whisper.cpp/build/src/libwhisper.so.1.8.4", BUILD_FOLDER"libwhisper.so.1.8.4");

    return 0;
}

int build_deps() {
    return build_whisper();
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
    return 0;
}
