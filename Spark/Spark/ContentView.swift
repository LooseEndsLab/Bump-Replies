//
//  ContentView.swift
//  Spark
//
//  Created by Aryan Mehra on 8/20/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MenuBarView().environmentObject(AppModel())
    }
}

#Preview {
    ContentView()
}
