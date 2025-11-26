//
//  WorkflowError.swift
//  ComputerUse
//

import Foundation

enum WorkflowError: LocalizedError {
    case emptyResponse
    case toolIterationLimit

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            "Model returned no choices."
        case .toolIterationLimit:
            "Reached tool-call iteration limit."
        }
    }
}
