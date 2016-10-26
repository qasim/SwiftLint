//
//  MixedIndentationRule
//  SwiftLint
//
//  Created by Qasim Iqbal on 13/07/2016.
//  Copyright (c) 2016 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework

public struct MixedIndentationRule: OptInRule, ConfigurationProviderRule {

    public var configuration = SeverityConfiguration(.Error)

    public init() {}

    public static let description = RuleDescription(
        identifier: "mixed_indentation",
        name: "Mixed Indentation",
        description: "Files should not have mixed tab and space indentation.",
        nonTriggeringExamples: [
            "func abc() {\n    if a > b {\n        return\n    }\n}\n"
        ],
        triggeringExamples: [
            "\t let a = 1\n    let b = 2"
        ]
    )

    public func validateFile(file: File) -> [StyleViolation] {
        // Matches exclusively spaces or tabs until followed by a mixture of tab and space
        let regularExpression = regex("^[\t ]*(\t | \t)")
        let commentsAndStrings = Set(SyntaxKind.commentAndStringKinds())

        return file.matchPattern(regularExpression).flatMap { match, syntaxKinds in
            // Avoid matches that are inside comments or strings
            guard commentsAndStrings.isDisjointWith(Set(syntaxKinds)) else {
                return nil
            }

            return StyleViolation(ruleDescription: self.dynamicType.description,
                severity: configuration.severity,
                location: Location(file: file, characterOffset: match.location))
        }
    }
}
