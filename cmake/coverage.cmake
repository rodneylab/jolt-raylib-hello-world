# Source: https://github.com/cmake-modules/lcov
#
# MIT License
#
# Copyright (c) 2020 cmake-modules
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function(add_coverage_target exclude)

    find_program(GCOV gcov)
    if (NOT GCOV)
        message(WARNING "program gcov not found")
    endif()

    find_program(LCOV lcov)
    if (NOT LCOV)
        message(WARNING "program lcov not found")
    endif()

    find_program(GENHTML genhtml)
    if (NOT GENHTML)
        message(WARNING "program genhtml not found")
    endif()

    if (LCOV AND GCOV AND GENHTML)
        #set(covname cov.info)
        set(covname lcov.txt)
        add_compile_options(-fprofile-arcs -ftest-coverage)
        add_link_options(--coverage)
        add_custom_target(cov DEPENDS ${covname})
        add_custom_command(
            OUTPUT  ${covname}
            COMMAND ${LCOV} -c -o ${covname} -d . -b . --gcov-tool ${GCOV}
            COMMAND ${LCOV} -r ${covname} -o ${covname} ${exclude} --exclude "*/SFML/System"  --exclude "*/catch2/*" --exclude "v1/*"
            COMMAND ${LCOV} -l ${covname}
            COMMAND ${GENHTML} ${covname} -output coverage
            COMMAND ${LCOV} -l ${covname} 2>/dev/null | grep Total | sed 's/|//g' | sed 's/Total://g' | awk '{print $1}' | sed s/%//g > coverage/total
        )
        set_directory_properties(PROPERTIES
            ADDITIONAL_CLEAN_FILES ${covname}
        )
    else()
        message(WARNING "unable to add target `cov`: missing coverage tools")
    endif()

endfunction()
