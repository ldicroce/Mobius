//
//  ContentView.swift
//  Mobius
//
//  Created by Luciano Di Croce on 9/8/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            SixtyMinuteGauge()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
