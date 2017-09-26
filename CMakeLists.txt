cmake_minimum_required(VERSION 3.3)
project(methylsaguaro)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -std=c++14 -O3 -w")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_HOME_DIRECTORY}/bin)

# include directory in find path where all dependency modules exist
include_directories(./)


# MethylSaguaro binaries
set(SOURCE_FILES_FREQ2HMMFEATURE ryggrad/src/base/ErrorHandling.cc ryggrad/src/base/FileParser.cc ryggrad/src/base/StringUtil.cc ryggrad/src/general/DNAVector.cc ryggrad/src/util/mutil.cc Saguaro/src/Freq2HMMFeature.cc Saguaro/src/HMMDistance.cc) 
set(SOURCE_FILES_HMMCLASSIFY  ryggrad/src/base/ErrorHandling.cc ryggrad/src/base/FileParser.cc ryggrad/src/base/StringUtil.cc Saguaro/src/HMMClassify.cc Saguaro/src/HMMDecode.cc ryggrad/src/util/mutil.cc) 
set(SOURCE_FILES_HMMTRAIN ryggrad/src/base/ErrorHandling.cc ryggrad/src/base/FileParser.cc ryggrad/src/general/DNAVector.cc ryggrad/src/base/StringUtil.cc Saguaro/src/HMMDecode.cc Saguaro/src/HMMDistance.cc Saguaro/src/HMMTrain.cc Saguaro/src/SOM.cc ryggrad/src/util/mutil.cc) 
set(SOURCE_FILES_LOCALTREES ryggrad/src/base/ErrorHandling.cc ryggrad/src/base/FileParser.cc ryggrad/src/general/DNAVector.cc ryggrad/src/base/StringUtil.cc Saguaro/src/HMMDecode.cc Saguaro/src/HMMDistance.cc Saguaro/src/LocalTrees.cc Saguaro/src/SOM.cc ryggrad/src/util/mutil.cc) 
set(SOURCE_FILES_METHYLSAGUARO ryggrad/src/base/ErrorHandling.cc ryggrad/src/base/FileParser.cc ryggrad/src/base/StringUtil.cc ryggrad/src/general/DNAVector.cc ryggrad/src/util/mutil.cc Saguaro/src/HMMDecode.cc Saguaro/src/HMMDistance.cc src/MethylSaguaro.cc) 

add_executable(Freq2HMMFeature ${SOURCE_FILES_FREQ2HMMFEATURE})
add_executable(HMMClassify ${SOURCE_FILES_HMMCLASSIFY})
add_executable(HMMTrain ${SOURCE_FILES_HMMTRAIN})
add_executable(LocalTrees ${SOURCE_FILES_LOCALTREES})
add_executable(MethylSaguaro ${SOURCE_FILES_METHYLSAGUARO})




