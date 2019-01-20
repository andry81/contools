#include "test_main.hpp"

#include <boost/program_options.hpp>


namespace po = boost::program_options;

int main(int argc, char **argv) {
    po::options_description desc("Allowed options");
    desc.add_options()
        ("help,h", "print usage message")

        ("data_in_root,i",
            po::value(&TestCaseStaticBase::s_TESTS_DATA_IN_ROOT.str()), "tests data input root directory path")
        ("data_out_root,o",
            po::value(&TestCaseStaticBase::s_TESTS_DATA_OUT_ROOT.str()), "tests data output root directory path")

        ("data_ref_dir,r",
            po::value(&TestCaseWithDataReference::s_TESTS_REF_DIR.str()), "tests data reference root directory path")
        ("disable_data_ref_tests",
            po::bool_switch(&TestCaseWithDataReference::s_is_TESTS_REF_DIR_disabled)->default_value(false), "disable tests required data reference root directory path")

        ("data_gen_dir,g",
            po::value(&TestCaseWithDataGenerator::s_TESTS_GEN_DIR.str()), "tests data generator root directory path")
        ("disable_data_gen_tests",
            po::bool_switch(&TestCaseWithDataGenerator::s_is_TESTS_GEN_DIR_disabled)->default_value(false), "disable tests required data generator root directory path")

        ("data_out_dir,o",
            po::value(&TestCaseWithDataOutput::s_TESTS_OUT_DIR.str()), "tests data output root directory path")
        ("disable_data_out_tests",
            po::bool_switch(&TestCaseWithDataOutput::s_is_TESTS_OUT_DIR_disabled)->default_value(false), "disable tests required data output root directory path")

        ("enable_interactive_tests",
            po::bool_switch(&TestCaseStaticBase::s_enable_interactive_tests)->default_value(false), "enable interactive tests, will wait on user input")
        ("enable_only_interactive_tests",
            po::bool_switch(&TestCaseStaticBase::s_enable_only_interactive_tests)->default_value(false), "enable only interactive tests, will wait on user input (overrides all --enable_*_tests flags)")
        ("enable_combinator_tests",
            po::bool_switch(&TestCaseStaticBase::s_enable_combinator_tests)->default_value(false), "enable combinator tests, might be real long and heavy")
        ("enable_all_tests",
            po::bool_switch(&TestCaseStaticBase::s_enable_all_tests)->default_value(false), "enable all tests")
        ;

    po::variables_map vm;
    po::store(po::command_line_parser(argc, argv).options(desc).allow_unregistered().run(), vm);
    po::notify(vm); // important, otherwise related option variables won't be initialized

    if (vm.count("help")) {
        std::cout << desc << "\n";
        printf("\nUnit tests command line:\n");
        ::testing::InitGoogleTest(&argc, argv);
        return 1;
    }

    if (TestCaseStaticBase::s_enable_all_tests) {
        TestCaseStaticBase::s_enable_interactive_tests = true;
        TestCaseStaticBase::s_enable_combinator_tests = true;
    }

    if (TestCaseStaticBase::s_enable_only_interactive_tests) {
        TestCaseStaticBase::s_enable_all_tests = false;
        TestCaseStaticBase::s_enable_interactive_tests = true;
        TestCaseStaticBase::s_enable_combinator_tests = false;
    }

    std::string gtest_filter;
    test::global_preinit(gtest_filter);

    ::testing::InitGoogleTest(&argc, argv);

    test::global_postinit(gtest_filter);

    const int res = RUN_ALL_TESTS();

    test::global_uninit();

    return res;
}
