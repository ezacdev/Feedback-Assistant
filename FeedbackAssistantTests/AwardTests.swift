import CoreData
import XCTest

@testable import FeedbackAssistant

final class AwardTests: BaseTestCase {

    let awards = Award.allAwards

    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(
                award.id,
                award.name,
                "Award ID should always match its name."
            )
        }
    }

    func testNewUserHasUnlockedNoAwards() {
        for award in awards {
            XCTAssertFalse(
                dataController.hasEarned(award: award),
                "New users should have no earned awards"
            )
        }
    }

    func testCreatingIssuesUnlocksAwards() {
        // thresholds for issue-based awards
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (index, value) in values.enumerated() {
            var issues = [Issue]()

            // create the required number of issues in the context
            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issues.append(issue)
            }

            // filter earned awards
            let matches = awards.filter { award in
                award.criterion == "issues"
                    && dataController.hasEarned(award: award)
            }

            // assert the expected number of unlocked awards
            XCTAssertEqual(
                matches.count,
                index + 1,
                "adding \(value) issues should unlock \(index + 1) awards."
            )

            // remove all issues to keep each iteration isolated
            dataController.deleteAll()
        }
    }
    func testClosedAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (index, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issue.completed = true
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criterion == "closed"
                    && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(
                matches.count,
                index + 1,
                "Completing \(value) issues should unlock \(index + 1) awards."
            )

            for issue in issues {
                dataController.delete(issue)
            }
        }
    }
}
