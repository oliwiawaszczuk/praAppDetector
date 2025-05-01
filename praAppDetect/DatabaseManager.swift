import SQLite3
import Foundation


public class DatabaseManager {
    let dbPath: String
    var db: OpaquePointer?
    let SQLITE_TRANSIENT: sqlite3_destructor_type
    
    public init(dbPath: String) {
        self.dbPath = dbPath
        self.SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    }
    
    public func connect() {
        if sqlite3_open(dbPath, &self.db) != SQLITE_OK {
            print("❌ Failed to open database")
        } else {
            print("✅ Successfully open database")
        }
    }
    
    func saveToDataBase(appName: String, description: String) {
        let timestamp = formatter.string(from: Date())

        let query = "INSERT INTO AppLogger(timestamp, appName, description) VALUES (?, ?, ?)"
        var stmt: OpaquePointer?
    
        if sqlite3_prepare_v2(self.db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, timestamp, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 2, appName, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(stmt, 3, description, -1, SQLITE_TRANSIENT)

            sqlite3_step(stmt)
            sqlite3_finalize(stmt)
        }
    }
    
    public func close() {
        if let db = self.db {
            sqlite3_close(db)
            print("✅ Successfully close database")
        } else {
            print("❌ Failed to close database")
        }
    }
}
