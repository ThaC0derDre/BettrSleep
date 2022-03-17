//
//  ContentView.swift
//  BettrSleep
//
//  Created by Andres Gutierrez on 3/15/22.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp       = defaultTime
    @State private var sleepAmount  = 8.0
    @State private var coffeeAmount = 1
    
    @State private var recSleepTime = ""
    static var defaultTime: Date {
        var component = DateComponents()
        component.hour      = 7
        component.minute    = 0
        return Calendar.current.date(from: component) ?? Date.now
    }
    
    
    var body: some View {
        NavigationView {
            Form{
                Section {
                    Text("When do you want to wake up?")
                            .font(.headline)
                    
                    HStack{
                        Spacer()
                    DatePicker("Select time to wake up", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .padding(.trailing)
                        
                        
                }
                }
                .listRowSeparator(.hidden)
                Section {
                    Text("How many hours of sleep would you like?")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25, onEditingChanged: { _ in
                        calculateSleep()
                    })
                        .padding(.horizontal)
                }
                .listRowSeparator(.hidden)
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                   
                    
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20, onEditingChanged: { _ in
                        calculateSleep()
                    })
                        .padding(.horizontal)
                }
                .listRowSeparator(.hidden)
                
                VStack(alignment: .center) {
                    
                    Text("You should sleep at \(recSleepTime) then!")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        
                }
            }
            .navigationTitle("BettrRest")
            .onAppear(perform: calculateSleep)
        }
        
    }
    
    func calculateSleep() {
        do{
            
            
            let config      = MLModelConfiguration()
            
            let model       = try SleepCalculator(configuration: config)
            
            let components  = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour        = (components.hour ?? 0) * 60 * 60
            let minute      = (components.minute ?? 0) * 60
            
            let prediction  = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime   = wakeUp - prediction.actualSleep
            
            recSleepTime    = sleepTime.formatted(date: .omitted, time: .shortened)
            
            
        }catch {
            
        }
     
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
