//
//  CanvasViewModel.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import UIKit
import Combine
//MARK: - CanvasViewModel - ViewModel -
class CanvasViewModel: ObservableObject {
    
    @Published var fetchedCanvas: [CanvasItemModel]
      @Published var selectedCanvas: [CanvasItemModel]
      @Published var isCanvasShowing: Bool
      
      private var cancellables = Set<AnyCancellable>()
      private let pexelsManager: PexelsManagerProtocol
      private var currentPage = 1
      
      init(pexelsManager: PexelsManagerProtocol,
           fetchedCanvas: [CanvasItemModel] = [],
           selectedCanvas: [CanvasItemModel] = [],
           isCanvasShowing: Bool = false) {
          self.pexelsManager = pexelsManager
          self.fetchedCanvas = fetchedCanvas
          self.selectedCanvas = selectedCanvas
          self.isCanvasShowing = isCanvasShowing
          
          loadPhotos()
          listenAddedItem()
      }
    
}

//MARK: - CanvasViewModel - extension - handler -
extension CanvasViewModel {
    
    func openCanvasSheet() {
        isCanvasShowing.toggle()
    }
    
    private func listenAddedItem() {
        $selectedCanvas
            .dropFirst()
            .sink { [weak self] _ in
                self?.isCanvasShowing = false
            }
            .store(in: &cancellables)
    }
}


//MARK: - CanvasViewModel - extension - fetcing systems -
extension CanvasViewModel {
    
    func loadPhotos() {
        pexelsManager.fetchPhotos(page: currentPage, perPage: 20)
            .receive(on: DispatchQueue.main)
            .flatMap { photos in
                let itemModels = photos.map { photo -> CanvasItemModel in
                    CanvasItemModel(id: photo.id, image: nil)
                }
                
                let imagePublishers = photos.map { photo -> AnyPublisher<UIImage?, Never> in
                    guard let url = URL(string: photo.src.small) else {
                        return Just(nil).eraseToAnyPublisher()
                    }
                    return URLSession.shared.dataTaskPublisher(for: url)
                        .retry(3)
                        .map { UIImage(data: $0.data) }
                        .replaceError(with: nil)
                        .eraseToAnyPublisher()
                }
                
                return Publishers.Zip(
                    Publishers.MergeMany(imagePublishers)
                        .collect(),
                    Just(itemModels)
                )
                .map { (images, models) in
                    zip(images, models).map { (image, model) -> CanvasItemModel in
                        var updatedModel = model
                        updatedModel.image = image
                        return updatedModel
                    }
                }
                .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching pexels photos: \(error)")
                    // Retry logic for error
                    currentPage += 1
                    loadPhotos()
                case .finished:
                    break
                }
            }, receiveValue: { newItems in
                let uniqueItems = newItems.filter { newItem in
                    !self.fetchedCanvas.contains(where: { $0.id == newItem.id })
                }
                self.fetchedCanvas.append(contentsOf: uniqueItems)
                self.currentPage += 1
            })
            .store(in: &cancellables)
    }
    
}
