//
//  SheetModifier.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import SwiftUI

struct SheetModifier: ViewModifier {
    
    let height: CGFloat
    let opacity: CGFloat
    
    init(_ height: CGFloat,
         opa opacity: CGFloat = 0.9) {
        self.height = height
        self.opacity = opacity
    }
    
    func body(content: Content) -> some View {
        content
            .presentationDetents([.fraction(height)])
            .presentationCornerRadius(32)
            .presentationBackgroundInteraction(.enabled)
    }
}
