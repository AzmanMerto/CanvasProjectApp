//
//  CanvasItemModel.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import UIKit

struct CanvasItemModel: Identifiable {
    
    var id: Int
    var image: UIImage?
    var size: CGSize
    
    init(id: Int = Int.random(in: 0...100),
         image: UIImage? = nil,
         size: CGSize = CGSize(width: 0.2, height: 0.15)) {
        self.id = id
        self.image = image
        self.size = size
    }
    
}
