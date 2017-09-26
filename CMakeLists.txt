cmake_minimum_required(VERSION 3.3)
project(methylsaguaro)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=c++14 -O3 -w")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_HOME_DIRECTORY}/bin)

# include directory in find path where all dependency modules exist
include_directories(./)


# MethylSaguaro binaries
set(SOURCE_FILES_FREQ2HMMFEATURE ryggrad/src/base/ErrorHandling.cc ryggrad/src/base/FileParser.cc ryggrad/src/base/StringUtil.cc ryggrad/src/general/DNAVector.cc ryggrad/src/util/mutil.cc Saguaro/src/Freq2HMMFeature.cc Saguaro/src/HMMDistance.cc) 
set(SOURCE_FILES_METHYLSAGUARO ryggrad/src/base/ErrorHandling.cc ryggrad/src/base/FileParser.cc ryggrad/src/base/StringUtil.cc ryggrad/src/general/DNAVector.cc ryggrad/src/util/mutil.cc Saguaro/src/HMMDecode.cc Saguaro/src/HMMDistance.cc src/MethylSaguaro.cc) 

add_executable(Freq2HMMFeature ${SOURCE_FILES_FREQ2HMMFEATURE})
add_executable(MethylSaguaro ${SOURCE_FILES_METHYLSAGUARO})




