include(FetchContent)
set(FETCHCONTENT_QUIET false)

FetchContent_Declare(
  photon
  # GIT_REPOSITORY https://github.com/alibaba/PhotonLibOS.git
  # GIT_TAG v0.5.6
  GIT_REPOSITORY https://github.com/yuchen0cc/PhotonLibOS.git
  GIT_TAG 8a1f8f97763286e3a3991b9634b05f62283e9021
)

if(BUILD_TESTING)
  set(BUILD_TESTING 0)
  FetchContent_MakeAvailable(photon)
  set(BUILD_TESTING 1)
else()
  FetchContent_MakeAvailable(photon)
endif()
set(PHOTON_INCLUDE_DIR ${photon_SOURCE_DIR}/include/)
