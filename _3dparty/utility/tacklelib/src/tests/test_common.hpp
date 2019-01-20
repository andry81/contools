#pragma once

#include <src/common.hpp>

// commons exclicitly for tests ONLY
#include <src/testlib/testlib.hpp>
#include <src/testlib/gtest_ext.hpp>

#include <tacklelib/utility/math.hpp>

#include <tacklelib/tackle/date_time.hpp>

#include <chrono>
#include <boost/filesystem.hpp>
#include <boost/regex.hpp>
#include <boost/range/combine.hpp>
#include <boost/iostreams/stream.hpp>
#include <boost/iostreams/device/file_descriptor.hpp>

#include <cstdint>
#include <cstdlib>
#include <iostream>


namespace boost
{
    namespace fs = filesystem;
    namespace ios = boost::iostreams;
}

// special value type to skip a specific test parameter check
struct Skip
{
};

const Skip skip = Skip{};
