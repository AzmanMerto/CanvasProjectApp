//
//  PexelsManager.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import Foundation
import Combine

protocol PexelsManagerProtocol {
    func fetchPhotos(page: Int, perPage: Int) -> AnyPublisher<[PexelsPhoto], Error>
}

class PexelsManager {
    
    private var cancellables = Set<AnyCancellable>()
        
    enum PexelsAPI {
        static let baseUrl = "https://api.pexels.com/v1"
        
        case curated(page: Int, perPage: Int)
        
        var url: URL? {
            switch self {
            case .curated(let page, let perPage):
                var components = URLComponents(string: PexelsAPI.baseUrl + "/curated")
                components?.queryItems = [
                    URLQueryItem(name: "page", value: "\(page)"),
                    URLQueryItem(name: "per_page", value: "\(perPage)")
                ]
                return components?.url
            }
        }
        
        var request: URLRequest? {
            guard let url = self.url else { return nil }
            var request = URLRequest(url: url)
            request.setValue(SecretKeys.shared.pexelsKey, forHTTPHeaderField: "Authorization")
            return request
        }
    }
    
}

extension PexelsManager: PexelsManagerProtocol {
    
    func fetchPhotos(page: Int, perPage: Int) -> AnyPublisher<[PexelsPhoto], Error> {
        guard let request = PexelsAPI.curated(page: page, perPage: perPage).request else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map(\.data)
            .decode(type: PexelsResponse.self, decoder: JSONDecoder())
            .map { $0.photos }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }


}
