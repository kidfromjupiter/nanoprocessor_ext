cmake_minimum_required(VERSION 3.16)
project(nanoprocessor_ext_vhdl LANGUAGES NONE)

find_program(GHDL_EXECUTABLE ghdl REQUIRED)

set(GHDL_STD "08" CACHE STRING "VHDL standard passed to GHDL (e.g. 93, 08)")
set(GHDL_WORKDIR "${CMAKE_BINARY_DIR}/ghdl_work" CACHE PATH "GHDL work library directory")
set(WAVES_DIR "${CMAKE_BINARY_DIR}/waves" CACHE PATH "Simulation waveform output directory")

set(GHDL_COMMON_FLAGS --std=${GHDL_STD} --workdir=${GHDL_WORKDIR})

set(DESIGN_SOURCES
    ${CMAKE_SOURCE_DIR}/Nano_Config_Pkg.vhd
    ${CMAKE_SOURCE_DIR}/Reg_8.vhd
    ${CMAKE_SOURCE_DIR}/RCA_8.vhd
    ${CMAKE_SOURCE_DIR}/Add_Sub_8.vhd
    ${CMAKE_SOURCE_DIR}/ALU_8.vhd
    ${CMAKE_SOURCE_DIR}/Reg_Bank_8.vhd
    ${CMAKE_SOURCE_DIR}/Bus_Mux_4_to_1_8.vhd
    ${CMAKE_SOURCE_DIR}/Register_Select_Mux_8.vhd
    ${CMAKE_SOURCE_DIR}/Seven_Seg_Hex_Display.vhd
    ${CMAKE_SOURCE_DIR}/Manual_Clock_Controller.vhd
    ${CMAKE_SOURCE_DIR}/Program_Counter_7.vhd
    ${CMAKE_SOURCE_DIR}/Program_ROM_16.vhd
    ${CMAKE_SOURCE_DIR}/Instruction_Decoder_16.vhd
    ${CMAKE_SOURCE_DIR}/MicroPC.vhd
    ${CMAKE_SOURCE_DIR}/Microcode_ROM.vhd
    ${CMAKE_SOURCE_DIR}/Control_Unit.vhd
    ${CMAKE_SOURCE_DIR}/Nanoprocessor_Ext.vhd
    ${CMAKE_SOURCE_DIR}/Nanoprocessor_Basys3.vhd
)

set(DESIGN_ENTITIES
    Reg_8
    RCA_8
    Add_Sub_8
    ALU_8
    Reg_Bank_8
    Bus_Mux_4_to_1_8
    Register_Select_Mux_8
    Seven_Seg_Hex_Display
    Manual_Clock_Controller
    Program_Counter_7
    Program_ROM_16
    Instruction_Decoder_16
    MicroPC
    Microcode_ROM
    Control_Unit
    Nanoprocessor_Ext
    Nanoprocessor_Basys3
)

add_custom_target(analyze_design
    COMMAND ${CMAKE_COMMAND} -E make_directory ${GHDL_WORKDIR}
    COMMAND ${GHDL_EXECUTABLE} -a ${GHDL_COMMON_FLAGS} ${DESIGN_SOURCES}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Analyzing design VHDL sources"
    VERBATIM
)

function(add_design_build_target entity_name)
    string(TOLOWER "${entity_name}" entity_lower)
    set(target_name "build_${entity_lower}")

    add_custom_target(${target_name}
        COMMAND ${GHDL_EXECUTABLE} -e ${GHDL_COMMON_FLAGS} ${entity_name}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        DEPENDS analyze_design
        COMMENT "Elaborating ${entity_name}"
        VERBATIM
    )

    set_property(GLOBAL APPEND PROPERTY DESIGN_BUILD_TARGETS ${target_name})
endfunction()

function(add_vhdl_testbench tb_entity tb_file stop_time)
    string(TOLOWER "${tb_entity}" tb_lower)
    set(analyze_target "analyze_${tb_lower}")
    set(build_target "build_${tb_lower}")
    set(sim_target "sim_${tb_lower}")
    set(wave_file "${WAVES_DIR}/${tb_entity}.ghw")

    add_custom_target(${analyze_target}
        COMMAND ${GHDL_EXECUTABLE} -a ${GHDL_COMMON_FLAGS} ${tb_file}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        DEPENDS analyze_design
        COMMENT "Analyzing ${tb_entity}"
        VERBATIM
    )

    add_custom_target(${build_target}
        COMMAND ${GHDL_EXECUTABLE} -e ${GHDL_COMMON_FLAGS} ${tb_entity}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        DEPENDS ${analyze_target}
        COMMENT "Elaborating ${tb_entity}"
        VERBATIM
    )

    add_custom_target(${sim_target}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${WAVES_DIR}
        COMMAND ${GHDL_EXECUTABLE} -r ${GHDL_COMMON_FLAGS} ${tb_entity} --stop-time=${stop_time} --wave=${wave_file}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        DEPENDS ${build_target}
        COMMENT "Running ${tb_entity} simulation -> ${wave_file}"
        VERBATIM
    )

    set_property(GLOBAL APPEND PROPERTY TESTBENCH_ANALYZE_TARGETS ${analyze_target})
    set_property(GLOBAL APPEND PROPERTY TESTBENCH_BUILD_TARGETS ${build_target})
    set_property(GLOBAL APPEND PROPERTY TESTBENCH_SIM_TARGETS ${sim_target})
endfunction()

foreach(entity_name IN LISTS DESIGN_ENTITIES)
    add_design_build_target(${entity_name})
endforeach()

get_property(DESIGN_BUILD_TARGETS GLOBAL PROPERTY DESIGN_BUILD_TARGETS)
add_custom_target(build_all DEPENDS ${DESIGN_BUILD_TARGETS})

add_vhdl_testbench(Reg_8_TB ${CMAKE_SOURCE_DIR}/Reg_8_TB.vhd 500ns)
add_vhdl_testbench(RCA_8_TB ${CMAKE_SOURCE_DIR}/RCA_8_TB.vhd 300ns)
add_vhdl_testbench(Add_Sub_8_TB ${CMAKE_SOURCE_DIR}/Add_Sub_8_TB.vhd 300ns)
add_vhdl_testbench(ALU_8_TB ${CMAKE_SOURCE_DIR}/ALU_8_TB.vhd 300ns)
add_vhdl_testbench(Reg_Bank_8_TB ${CMAKE_SOURCE_DIR}/Reg_Bank_8_TB.vhd 600ns)
add_vhdl_testbench(Bus_Mux_4_to_1_8_TB ${CMAKE_SOURCE_DIR}/Bus_Mux_4_to_1_8_TB.vhd 300ns)
add_vhdl_testbench(Register_Select_Mux_8_TB ${CMAKE_SOURCE_DIR}/Register_Select_Mux_8_TB.vhd 300ns)
add_vhdl_testbench(Seven_Seg_Hex_Display_TB ${CMAKE_SOURCE_DIR}/Seven_Seg_Hex_Display_TB.vhd 300ns)
add_vhdl_testbench(Manual_Clock_Controller_TB ${CMAKE_SOURCE_DIR}/Manual_Clock_Controller_TB.vhd 500ns)
add_vhdl_testbench(Program_Counter_7_TB ${CMAKE_SOURCE_DIR}/Program_Counter_7_TB.vhd 400ns)
add_vhdl_testbench(Instruction_Decoder_16_TB ${CMAKE_SOURCE_DIR}/Instruction_Decoder_16_TB.vhd 300ns)
add_vhdl_testbench(Nanoprocessor_Ext_TB ${CMAKE_SOURCE_DIR}/Nanoprocessor_Ext_TB.vhd 8us)

get_property(TESTBENCH_ANALYZE_TARGETS GLOBAL PROPERTY TESTBENCH_ANALYZE_TARGETS)
get_property(TESTBENCH_BUILD_TARGETS GLOBAL PROPERTY TESTBENCH_BUILD_TARGETS)
get_property(TESTBENCH_SIM_TARGETS GLOBAL PROPERTY TESTBENCH_SIM_TARGETS)

function(serialize_targets)
    set(previous_target "")
    foreach(current_target IN LISTS ARGN)
        if(previous_target)
            add_dependencies(${current_target} ${previous_target})
        endif()
        set(previous_target ${current_target})
    endforeach()
endfunction()

# GHDL updates the same work library metadata file; serialize these target groups.
serialize_targets(${TESTBENCH_ANALYZE_TARGETS})
serialize_targets(${TESTBENCH_BUILD_TARGETS})
serialize_targets(${TESTBENCH_SIM_TARGETS})

add_custom_target(analyze_testbenches DEPENDS ${TESTBENCH_ANALYZE_TARGETS})
add_custom_target(build_testbenches DEPENDS ${TESTBENCH_BUILD_TARGETS})
add_custom_target(sim_all DEPENDS ${TESTBENCH_SIM_TARGETS})
