//
//  InspirationGenerator.swift
//  Echo
//
//  Created by Isis Anchalee on 3/17/16.
//  Copyright © 2016 echo. All rights reserved.
//

import UIKit

struct InspirationGenerator {
    static let quotes = [
        ["\"Do it big, do it right, and do it with style.\"", "Fred Astaire"],
        ["\"Life is the dancer and you are the dance.\"", "Eckhart Tolle"],
        ["\"Dancing is like dreaming with your feet.\"", "Constanze"],
        ["\"It takes an athlete to dance, but an artist to be a dancer.\"", "Shanna LaFleur"],
        ["\"Dance is the only art of which we ourselves are the stuff of which it is made.\"", "Ted Shawn"],
        ["\"I'm not interested in how people move, but what moves them.\"", "Pina Bausch"],
        ["\"Dance is music made visible.\"", "Unknown"],
        ["\"It's not about being the best. It's about being better than you were yesterday.\"", "Unknown"],
        ["\"The only dancer you should compare yourself to, is the one you used to be.\"", "Unknown"],
        ["\"Practice like you've never won. Perform like you've never lost.\"", "Unknown"],
        ["\"Take time to do what makes your soul happy.'", "Unknown"],
        ["'Don't practice until you get it right. Practice until you can't get it wrong.\"", "Unknown"],
        ["\"You don't stop dancing because you grow old, you grow old because you stop dancing.\"", "Unknown"],
        ["\"Everything in the universe has rhythm. Everything dances.\"", "Maya Angelou"],
        ["\"I grew up with six brothers. That's how I learned to dance--waiting for the bathroom.\"", "Bob Hope"]]
    
    static func pickRandomQuote() -> [String] {
        let maxLength = quotes.count - 1
        let randomIndex = Int(arc4random_uniform(UInt32(maxLength)) + 1)
        return quotes[randomIndex]
    }
}
