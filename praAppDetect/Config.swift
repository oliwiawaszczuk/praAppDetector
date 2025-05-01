import Foundation

public let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "Europe/Warsaw")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()
