//
//  HealthKitManager.swift
//  LusciiHealthKitSpike
//
//  Created by Rik van den Brule on 04/02/2020.
//  Copyright © 2020 Rik van den Brule. All rights reserved.
//

import HealthKit

class HealthKitManager: ObservableObject {

    private let healthStore = HKHealthStore()

    @Published var result = "No Data"
    @Published var healthKitAccess = "Healthkit Access: Unknown"

    func requestAccess() {
        healthStore.requestAuthorization(toShare: nil, read:
            [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
            ]
        ) { (success, error) in
            DispatchQueue.main.async {
                if success {
                    self.healthKitAccess = "Healthkit Access: Granted"
                }
                if let error = error {
                    self.healthKitAccess = "Healthkit Access: Error \(error.localizedDescription)"
                }
            }
        }
    }

    func retrieveAverageSteps(daysBack: Int) {

        let predicate = createPredicateForTimePeriod(daysBack: daysBack)

        let quantity = HKQuantityType.quantityType(forIdentifier: .stepCount)!

        let query = HKStatisticsQuery(quantityType: quantity,
                                      quantitySamplePredicate: predicate,
                                      options: .cumulativeSum) { query, result, error in
            DispatchQueue.main.async {
                if let result = result {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .none
                    let steps = ( result.sumQuantity()?.doubleValue(for: .count()) ?? 0 ) / Double(daysBack)
                    self.result = formatter.string(for: steps) ?? "0"
                }

                if let error = error {
                    self.result = "Error: \(error.localizedDescription)"
                }
            }
        }
        healthStore.execute(query)
    }

    func retrieveAverageSleep(daysBack: Int) {
        let predicate = createPredicateForTimePeriod(daysBack: daysBack)

        let sample = HKSampleType.categoryType(forIdentifier: .sleepAnalysis)!

        let query = HKSampleQuery(sampleType: sample,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { (query, samples, error) in
            guard let samples = samples else {
                return
            }

            let totalInBedTime = samples
                .map { $0 as! HKCategorySample }
                .filter { $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue }
                .reduce(0.0) { $0 + $1.duration }

            DispatchQueue.main.async {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute]
                formatter.formattingContext = .standalone
                self.result = formatter.string(from: totalInBedTime / Double(daysBack)) ?? "Unknown"
            }
        }

        healthStore.execute(query)
    }

    private func createPredicateForTimePeriod(daysBack: Int) -> NSPredicate {
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let today = calendar.date(from: todayComponents)!
        let yesterday = calendar.date(byAdding: .day, value: -daysBack, to: today)!
        return HKQuery.predicateForSamples(withStart: yesterday, end: today, options: .strictStartDate)
    }
}
