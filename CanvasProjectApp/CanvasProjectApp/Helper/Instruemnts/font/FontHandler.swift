//
//  FontHandler.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import SwiftUI

struct FontHandler {
    
    static func makeFont(_ with: FontHelper.fonts) -> Font {
        switch with {
        case .system16:
            FontHelper.system16
        }
    }
    
}
