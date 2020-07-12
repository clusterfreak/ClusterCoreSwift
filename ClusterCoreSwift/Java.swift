/**
* Java Functions
* @version 0.0.2 (2020-05-24)
* @author Thomas Heym
*/

import Foundation

struct Math {
    private static var seeded = false
    static func random() -> Double {
        if !Math.seeded {
            let time = Int(NSDate().timeIntervalSinceReferenceDate)
            srand48(time)
            Math.seeded = true
        }
        return Double(drand48())
    }
}
