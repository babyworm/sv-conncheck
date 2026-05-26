#pragma once
#include "Checker.h"
namespace connect {
// Emits Issues from ConnectionGraph::synthRisks (populated by
// ConnectionExtractor's procedural-block walk). Primary rule findings
// (register-file inferred as latch/memory) are ERROR severity so they
// can gate a pipeline; secondary findings are WARN.
class SynthesizabilityChecker : public IChecker {
public:
    std::vector<Issue> check(const ConnectionGraph& graph) const override;
};
} // namespace connect
