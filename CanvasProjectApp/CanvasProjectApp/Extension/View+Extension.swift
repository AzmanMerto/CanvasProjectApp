//
//  View+Extension.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import SwiftUI

extension View {
    
    /// Dynamic Width
    /// - Parameter double: Width double for dynamic structure (default is nil)
    /// - Parameter consSize: Optional enum to provide a default size value (default is .size9)
    /// - Returns: Makes a dynamic width adjustment according to the screen size
    func dw(_ double: Double? = nil, consSize: ConsSize = .size9) -> Double {
        let uiWidth = UIScreen.main.bounds.width
        
        if let double = double {
            return uiWidth * double
        } else {
            return uiWidth * consSize.rawValue
        }
    }

    /// Dynamic Height
    /// - Parameter double: Height double for dynamic structure (default is nil)
    /// - Parameter consSize: Optional enum to provide a default size value (default is .size9)
    /// - Returns: Makes a dynamic height adjustment according to the screen size
    func dh(_ double: Double? = nil, consSize: ConsSize = .size9) -> Double {
        let uiHeight = UIScreen.main.bounds.height
        
        if let double = double {
            return uiHeight * double
        } else {
            return uiHeight * consSize.rawValue
        }
    }

}
