#include "SynthesizabilityChecker.h"

namespace connect {

std::vector<Issue> SynthesizabilityChecker::check(const ConnectionGraph& graph) const {
    std::vector<Issue> issues;
    issues.reserve(graph.synthRisks.size());
    for (const auto& risk : graph.synthRisks) {
        Issue issue;
        issue.type = Issue::Type::SYNTH_RISK;
        issue.severity = risk.isError ? Issue::Severity::ERROR : Issue::Severity::WARN;
        // Render the offending array/signal as "<scope>.<signal>" via the
        // shared PortInfo path so existing report generators surface it
        // without special-casing.
        issue.port.instancePath = risk.scopePath;
        issue.port.portName = risk.signal;
        issue.port.location = risk.location;
        issue.detail = risk.detail;
        issue.lineNumber = risk.lineNumber;
        issue.columnNumber = risk.columnNumber;
        issues.push_back(std::move(issue));
    }
    return issues;
}

} // namespace connect
