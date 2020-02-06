//
//  HKSample+duration.swift
//  LusciiHealthKitSpike
//
//  Created by Rik van den Brule on 14/01/2020.
//  Copyright © 2020 Rik van den Brule. All rights reserved.
//

import HealthKit

extension HKSample {
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}

