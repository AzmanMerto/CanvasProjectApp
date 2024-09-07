//
//  ColorHandler.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import SwiftUI

struct ColorHandler {
    
    static func makeMainColor(_ with: ColorHelper.mainColor) -> Color {
        Color(with.rawValue)
    }
    
}
