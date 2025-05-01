import AppKit


class AppMonitor {
    static var lastAppName = ""

    static func startMonitoring() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let apps = NSWorkspace.shared.runningApplications
            if let activeApp = apps.first(where: {
                $0.isActive && $0.activationPolicy == .regular
            }), activeApp != NSRunningApplication.current {

                let appName = activeApp.localizedName ?? "Unknown"
                
                if appName != lastAppName {
                    databaseManager.saveToDataBase(appName: appName, description: activeApp.processIdentifier.description)
                    lastAppName = appName
                }
            }
        }

        RunLoop.current.add(timer, forMode: .common)
    }
}
