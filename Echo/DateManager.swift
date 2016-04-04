//
//  DateManager.swift
//  Echo
//
//  Created by Isis Anchalee on 3/10/16.
//  Copyright © 2016 echo. All rights reserved.
//


import UIKit

class DateManager {
    class var defaultFormatter: NSDateFormatter {
        struct Static {
            static let instance: NSDateFormatter = NSDateFormatter()
        }
        Static.instance.dateFormat = "MMMM dd, yyyy"
        
        return Static.instance
    }
    
    class var detailedFormatter: NSDateFormatter {
        struct Static {
            static let instance: NSDateFormatter = NSDateFormatter()
        }
        Static.instance.dateFormat = "MM/dd/yy, hh:mm a"
        
        return Static.instance
    }
    
    class var shortFormatter: NSDateFormatter {
        struct Static {
            static let instance: NSDateFormatter = NSDateFormatter()
        }
        Static.instance.dateFormat = "MMM dd"
        
        return Static.instance
    }
    
    class var wordDayFormatter: NSDateFormatter {
        struct Static {
            static let instance: NSDateFormatter = NSDateFormatter()
        }
        Static.instance.dateFormat = "EEEE"
        
        return Static.instance
    }
    
    
    class var onlyDayFormatter: NSDateFormatter {
        struct Static {
            static let instance: NSDateFormatter = NSDateFormatter()
        }
        Static.instance.dateFormat = "dd"
        
        return Static.instance
    }
    
    class var onlyMonthAndYearFormatter: NSDateFormatter {
        struct Static {
            static let instance: NSDateFormatter = NSDateFormatter()
        }
        Static.instance.dateFormat = "MMMM yyyy"
        
        return Static.instance
    }
    
    class var timeOnlyFormatter: NSDateFormatter {
        struct Static {
            static let instance: NSDateFormatter = NSDateFormatter()
        }
        Static.instance.dateFormat = "h:mm a"
        
        return Static.instance
    }
    
    class func getFriendlyTime(fromDate: NSDate!) -> String {
        let interval = fromDate.timeIntervalSinceNow
        
        func getTimeData(value: NSTimeInterval) -> Int {
            let count = Int(floor(value))
            return count
        }
        
        let value = -interval
        switch value {
        case 0...15: return "now"
            
        case 0..<60:
            let timeData = getTimeData(value)
            return "\(timeData)s"
            
        case 0..<3600:
            let timeData = getTimeData(value/60)
            return "\(timeData)m"
            
        case 0..<86400:
            let timeData = getTimeData(value/3600)
            return "\(timeData)h"
            
        default:
            return shortFormatter.stringFromDate(fromDate)
        }
    }
}

public func <(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedAscending
}

public func ==(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedSame
}

extension NSDate: Comparable { }
