//
//  DispatchSourceDemoApp.swift
//  DispatchSourceDemo
//
//  Created by Jeffrey Blagdon (work) on 2022-10-20.
//

import SwiftUI

@main
struct DispatchSourceDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(interactor: try! ConcreteInteractor())
                .frame(idealWidth: 2000, idealHeight: 2000)
        }
    }
}
