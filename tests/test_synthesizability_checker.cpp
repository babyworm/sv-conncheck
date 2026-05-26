#include <catch2/catch_test_macros.hpp>

#include "ConnectionExtractor.h"
#include "SynthesizabilityChecker.h"
#include "TestUtils.h"

#include <string>
#include <vector>

using namespace connect;

namespace {

// Compile a fixture under tests/fixtures/ and run the synthesizability
// checker over the extracted graph for the given top module.
std::vector<Issue> runSynthCheck(const std::string& fixture, const std::string& top) {
    std::string path = std::string(TEST_FIXTURES_DIR) + "/" + fixture;
    auto compiled = testutils::compileFile(path);
    REQUIRE(static_cast<bool>(compiled));
    ConnectionExtractor extractor(*compiled.compilation, top);
    auto graph = extractor.extract();
    SynthesizabilityChecker checker;
    return checker.check(graph);
}

} // namespace

TEST_CASE("SynthesizabilityChecker: variable-index partial regfile write + comb read is ERROR", "[synth]") {
    auto issues = runSynthCheck("latch_regfile_bug.sv", "latch_regfile_bug");
    // Exactly one primary-rule finding for the `px` register file.
    REQUIRE(issues.size() == 1);
    CHECK(issues[0].type == Issue::Type::SYNTH_RISK);
    CHECK(issues[0].severity == Issue::Severity::ERROR);
    CHECK(issues[0].port.portName == "px");
    CHECK(issues[0].lineNumber > 0);
    CHECK(issues[0].detail.find("ELAB-978") != std::string::npos);
    CHECK(issues[0].detail.find("latch/memory") != std::string::npos);
}

TEST_CASE("SynthesizabilityChecker: explicit full next-state register file is clean", "[synth]") {
    auto issues = runSynthCheck("latch_regfile_fixed.sv", "latch_regfile_fixed");
    CHECK(issues.empty());
}

TEST_CASE("SynthesizabilityChecker: legit two-port SRAM (registered read) is clean", "[synth]") {
    auto issues = runSynthCheck("latch_sram_tp.sv", "latch_sram_tp");
    CHECK(issues.empty());
}

TEST_CASE("SynthesizabilityChecker: incomplete always_comb assignment is WARN (secondary rule)", "[synth]") {
    auto issues = runSynthCheck("latch_incomplete_comb.sv", "latch_incomplete_comb");
    // Only the no-else `y_latch` is flagged; the default-then-override and
    // the complete if/else signals stay clean.
    REQUIRE(issues.size() == 1);
    CHECK(issues[0].type == Issue::Type::SYNTH_RISK);
    CHECK(issues[0].severity == Issue::Severity::WARN);
    CHECK(issues[0].port.portName == "y_latch");
    CHECK(issues[0].detail.find("infer a latch") != std::string::npos);
}
