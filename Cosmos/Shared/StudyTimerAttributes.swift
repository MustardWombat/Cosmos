//
//  StudyTimerAttributes.swift
//  Cosmos
//
//  Created by James Williams on 4/6/25.
//
import Foundation
import ActivityKit

struct StudyTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: Int
        var endDate: Date
    }

    var topic: String
}
