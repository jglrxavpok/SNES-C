cmake_minimum_required(VERSION 3.13)

project(TestSNES)

add_custom_target(MakeImage
        COMMAND make clean && make
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

add_custom_target(Play
        COMMAND snes9x-gtk ${PROJECT_NAME}.sfc
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        DEPENDS MakeImage
)
