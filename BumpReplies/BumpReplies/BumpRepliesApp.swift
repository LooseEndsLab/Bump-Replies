//
//  BumpRepliesApp.swift
//  BumpReplies
//
//  Created by Aryan Mehra on 8/20/26.
//

import SwiftUI

@main
struct BumpRepliesApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra("BumpReplies", systemImage: "arrowshape.turn.up.left.circle") {
            MenuBarView()
                .environmentObject(model)
                .tint(model.accentColor.color)
        }
        .menuBarExtraStyle(.window)

        Window("Settings", id: "settings") {
            SettingsView()
                .environmentObject(model)
                .tint(model.accentColor.color)
        }
    }
}
