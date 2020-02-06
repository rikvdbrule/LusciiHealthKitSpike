//
//  ContentView.swift
//  LusciiHealthKitSpike
//
//  Created by Rik van den Brule on 09/01/2020.
//  Copyright © 2020 Rik van den Brule. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject
    private var healthKitManager: HealthKitManager

    @State
    private var days = 1

    var body: some View {
        VStack {
            Spacer()
            Text(healthKitManager.result)
                .font(.largeTitle)
            Text("Average Steps")
                .font(.caption)
            Stepper("last \(days) days", value: $days, in: 1...31)
                .padding()
            Button(action: {
                self.healthKitManager.retrieveAverageSteps(daysBack: self.days)
//                self.healthKitManager.retrieveAverageSleep(daysBack: self.days)
            }) {
                Text("Retrieve")
            }

            Spacer()

            Text(healthKitManager.healthKitAccess)
            Button(action: {
                self.healthKitManager.requestAccess()
            }) {
                Text("Request Access")
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(HealthKitManager())
    }
}
