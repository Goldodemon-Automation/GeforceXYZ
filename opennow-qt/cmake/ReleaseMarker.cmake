# Release artifact marker.
#
# Every published package carries a file literally named "@Release" at its root,
# so a download can be identified as a release payload without unpacking a
# binary, and so the packaging contract tests can tell a release package apart
# from a stray install tree.
#
# The values come from the same metadata CPack uses, so a nightly or supporter
# build is labelled with its own name and version without further wiring.

set(OPENNOW_RELEASE_MARKER_NAME "@Release")
set(OPENNOW_RELEASE_MARKER_PATH "${CMAKE_CURRENT_BINARY_DIR}/@Release")

if(OPENNOW_BUILD_VERSION)
    set(OPENNOW_RELEASE_MARKER_VERSION "${OPENNOW_BUILD_VERSION}")
elseif(CPACK_PACKAGE_VERSION)
    set(OPENNOW_RELEASE_MARKER_VERSION "${CPACK_PACKAGE_VERSION}")
else()
    set(OPENNOW_RELEASE_MARKER_VERSION "0.0.0")
endif()

if(OPENNOW_NUMERIC_VERSION)
    set(OPENNOW_RELEASE_MARKER_NUMERIC "${OPENNOW_NUMERIC_VERSION}")
else()
    set(OPENNOW_RELEASE_MARKER_NUMERIC "${OPENNOW_RELEASE_MARKER_VERSION}")
endif()

if(CPACK_PACKAGE_NAME)
    set(OPENNOW_RELEASE_MARKER_PRODUCT "${CPACK_PACKAGE_NAME}")
else()
    set(OPENNOW_RELEASE_MARKER_PRODUCT "OpenNOW")
endif()

if(OPENNOW_PACKAGE_ARCH)
    set(OPENNOW_RELEASE_MARKER_ARCH "${OPENNOW_PACKAGE_ARCH}")
else()
    set(OPENNOW_RELEASE_MARKER_ARCH "${CMAKE_SYSTEM_PROCESSOR}")
endif()

# Source revision, for support reports. Absent in a source export or a test
# fixture, which is why it degrades to "unknown" instead of failing the build.
set(OPENNOW_RELEASE_MARKER_COMMIT "unknown")
find_package(Git QUIET)
if(Git_FOUND)
    execute_process(
        COMMAND "${GIT_EXECUTABLE}" rev-parse --short=12 HEAD
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/.."
        OUTPUT_VARIABLE OPENNOW_RELEASE_MARKER_COMMIT
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
        RESULT_VARIABLE OPENNOW_RELEASE_MARKER_COMMIT_RESULT
    )
    if(NOT OPENNOW_RELEASE_MARKER_COMMIT_RESULT EQUAL 0)
        set(OPENNOW_RELEASE_MARKER_COMMIT "unknown")
    endif()
endif()

string(TIMESTAMP OPENNOW_RELEASE_MARKER_BUILT "%Y-%m-%dT%H:%M:%SZ" UTC)

file(WRITE "${OPENNOW_RELEASE_MARKER_PATH}"
"name: ${OPENNOW_RELEASE_MARKER_PRODUCT}
version: ${OPENNOW_RELEASE_MARKER_VERSION}
version_numeric: ${OPENNOW_RELEASE_MARKER_NUMERIC}
platform: ${CMAKE_SYSTEM_NAME}
architecture: ${OPENNOW_RELEASE_MARKER_ARCH}
commit: ${OPENNOW_RELEASE_MARKER_COMMIT}
built: ${OPENNOW_RELEASE_MARKER_BUILT}
")

# The marker belongs to the payload root, next to the bin/ directory that the
# portable ZIP and the installed application both use.
install(FILES "${OPENNOW_RELEASE_MARKER_PATH}"
    DESTINATION "."
    RENAME "${OPENNOW_RELEASE_MARKER_NAME}"
)
