//
//  SmartastroApp.swift
//  Smartastro
//
//  Created by AmineBj on 11/12/24.
//

import SwiftUI

@main
struct SmartastroApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
