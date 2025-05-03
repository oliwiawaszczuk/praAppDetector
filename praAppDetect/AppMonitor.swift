import AppKit
import Foundation
import AXSwift

class AppMonitor {
    static var lastAppName = ""
    static var lastProjectPath: String?
    
    static func startMonitoring() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let activeApp = NSWorkspace.shared.frontmostApplication,
                  activeApp.activationPolicy == .regular,
                  activeApp != NSRunningApplication.current else { return }
            
            let appName = activeApp.localizedName ?? "Unknown"
            var projectPath: String? = nil
            
            if jetBrainsFixed.keys.contains(appName) {
                projectPath = getJetBrainsProjectPath(appName: appName)
            }
            
            if appName != lastAppName || projectPath != lastProjectPath {
                var description = "PID: \(activeApp.processIdentifier)"
                if projectPath != nil, jetBrainsFixed.keys.contains(appName) {
                    description = projectPath!
                }
                databaseManager.saveToDataBase(appName: appName, description: description)
                
                lastAppName = appName
                lastProjectPath = projectPath
            }
        }
        
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private static func getJetBrainsProjectPath(appName: String) -> String? {
        let jetBrainsAppPath = jetBrainsFixed[appName] ?? appName
        
        guard jetBrainsAppPath != appName else { return nil }
        
        let fullPath = NSString(string: jetBrainsAppPath).expandingTildeInPath
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)),
              let xmlString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        let pattern = "<entry key=\"([^\"]+)\"[^>]*>\\s*<value>\\s*<RecentProject[^>]*>"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: xmlString, range: NSRange(xmlString.startIndex..., in: xmlString))
            
            guard let lastMatch = matches.last else {
                return nil
            }
            
            let keyRange = lastMatch.range(at: 1)
            guard keyRange.location != NSNotFound,
                  let range = Range(keyRange, in: xmlString) else {
                return nil
            }
            
            var projectPath = String(xmlString[range])
            
            projectPath = projectPath.replacingOccurrences(of: "$USER_HOME$", with: NSHomeDirectory())
            
            return projectPath
        } catch {
            print("Regex error: \(error)")
            return nil
        }
    }
}
