import Foundation
import IOKit.ps
import AppKit
import Cocoa


let databaseManager = DatabaseManager(dbPath: "/Users/praoliwia/Library/Application Support/com.praCompany/praLog.sqlite")

databaseManager.connect()

let systemObserver = SystemObserver(databaseManager: databaseManager)
AppMonitor.startMonitoring()

let app = NSApplication.shared
app.delegate = systemObserver

NSApp.run()
