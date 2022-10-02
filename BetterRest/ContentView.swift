//
//  ContentView.swift
//  BetterRest
//
//  Created by William Young on 01/10/2022.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0 {
        didSet {
            sleepTime = calculateBedtime()
        }
    }
    @State private var wakeUp = defaultWakeTime {
        didSet {
            sleepTime = calculateBedtime()
        }
    }
    @State private var coffeeAmount = 1 {
        didSet {
           sleepTime = calculateBedtime()
        }
    }
    
    @State private var sleepTime = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationView{
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a tine:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section {
                    Text("Desired amount of sleep:")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section {
                    Text("Daily coffee intake:")
                        .font(.headline)
                    
                    Picker(coffeeAmount == 1 ? "\(coffeeAmount) cup" : "\(coffeeAmount) cups", selection: $coffeeAmount){
                        ForEach(1..<22) {
                            Text("\($0 - 1)")
                        }
                    }
                }
                
                Section {
                    Text("Your reccomended bedtime is:")
                        .font(.headline)
                    Text("\(calculateBedtime())")
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedtime()-> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculater(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            sleepTime = "Something went wrong :/"
        }
        return sleepTime
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
