//
//  PexelsModel.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import Foundation

struct PexelsPhoto: Codable, Identifiable {
    let id: Int
    let src: PexelsPhotoSource
}

struct PexelsPhotoSource: Codable {
    let original: String
    let small: String
    let large: String
}

struct PexelsResponse: Codable {
    let photos: [PexelsPhoto]
}
