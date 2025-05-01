import Cocoa


public class SystemObserver: NSObject, NSApplicationDelegate {
    private let databaseManager: DatabaseManager
    private static var instance: SystemObserver?
    
    public init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
        
        super.init()
        
        SystemObserver.instance = self
        signalHandler()
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenIsLocked),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenIsUnlocked),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )
    }
    
    private func signalHandler() {
        signal(SIGTERM) { signal in
            SystemObserver.instance?.handleSignal(signal)
            exit(signal)
        }
        signal(SIGINT) { signal in
            SystemObserver.instance?.handleSignal(signal)
            exit(signal)
        }
        signal(SIGHUP) { signal in
            SystemObserver.instance?.handleSignal(signal)
            exit(signal)
        }
    }
    
    private func handleSignal(_ signal: Int32) {
        databaseManager.saveToDataBase(
            appName: "SYSTEM EXIT",
            description: "Sygnał: \(signal)"
        )
    }

    @objc func systemWillSleep(notification: Notification) {
        self.databaseManager.saveToDataBase(appName: "SYSTEM EXIT", description: "System będzie usypiany")
    }

    @objc func systemDidWake(notification: Notification) {
        self.databaseManager.saveToDataBase(appName: "SYSTEM EXIT", description: "System został wybudzony")
    }
    
    @objc func screenIsLocked(notification: Notification) {
        self.databaseManager.saveToDataBase(appName: "SYSTEM EXIT", description: "Ekran został zablokowany")
    }
    
    @objc func screenIsUnlocked(notification: Notification) {
        self.databaseManager.saveToDataBase(appName: "SYSTEM EXIT", description: "Ekran został odblokowany")
    }
}
