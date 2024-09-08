//
//  CanvasItemModel.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import UIKit

struct CanvasItemModel: Identifiable {
    
    let id: Int
    var image: UIImage?
    var size: CGSize
    var position: CGPoint
    
    init(id: Int = Int.random(in: 0...100),
         image: UIImage? = nil,
         size: CGSize = CGSize(width: 0.2, height: 0.15),
         position: CGPoint = CGPoint(
            x: (UIScreen.main.bounds.width ) / 2.2,
            y: (UIScreen.main.bounds.height ) / 2.8
         )) {
             self.id = id
             self.image = image
             self.size = size
             self.position = position
         }
    
}
