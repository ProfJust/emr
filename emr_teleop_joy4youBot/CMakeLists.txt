cmake_minimum_required(VERSION 2.8.3)
project(emr_teleop_joy4youBot)

## Use C++11
add_definitions(--std=c++11)

## Find catkin macros and libraries
find_package(catkin REQUIRED COMPONENTS
  roscpp
  geometry_msgs
  sensor_msgs
)

###################################
## catkin specific configuration ##
###################################
## The catkin_package macro generates cmake config files for your package
## Declare things to be passed to dependent projects
## INCLUDE_DIRS: uncomment this if you package contains header files
## LIBRARIES: libraries you create in this project that dependent projects also need
## CATKIN_DEPENDS: catkin_packages dependent projects also need
## DEPENDS: system dependencies of this project that dependent projects also need
catkin_package(
  INCLUDE_DIRS
   # include
#  LIBRARIES
  CATKIN_DEPENDS 
    roscpp
    geometry_msgs
    sensor_msgs
#  DEPENDS 
)

###########
## Build ##
###########

## Specify additional locations of header files
## Your package locations should be listed before other locations
include_directories(
  include
   ${catkin_INCLUDE_DIRS}/emr/emr_teleop_joy4youBot
)

## Declare a C++ executable
add_executable(${PROJECT_NAME}
  ${PROJECT_NAME}.cpp
)


## Specify libraries to link a library or executable target against
target_link_libraries(${PROJECT_NAME}
  ${catkin_LIBRARIES}
)



