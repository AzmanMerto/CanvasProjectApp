//
//  CanvasViewModel.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import SwiftUI
import Combine

//MARK: - CanvasViewModel - ViewModel -
class CanvasViewModel: ObservableObject {
    
    @Published var fetchedCanvas: [CanvasItemModel]
    @Published var selectedCanvas: [CanvasItemModel]
    @Published var activedCanvas: CanvasItemModel?
    @Published var isCanvasShowing: Bool
    
    private let pexelsManager: PexelsManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    
    init(fetchedCanvas: [CanvasItemModel] = [],
         selectedCanvas: [CanvasItemModel] = [],
         activedCanvas: CanvasItemModel? = nil,
         
         isCanvasShowing: Bool = false,
         
         pexelsManager: PexelsManagerProtocol) {
        self.fetchedCanvas = fetchedCanvas
        self.activedCanvas = activedCanvas
        self.selectedCanvas = selectedCanvas
        
        self.isCanvasShowing = isCanvasShowing
        
        self.pexelsManager = pexelsManager
        
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
//MARK: - CanvasViewModel - extension - item helper funcs -
extension CanvasViewModel {
 
    func selectCanvas(_ model: CanvasItemModel) {
        activedCanvas = model
    }
    
    func checkSelectedCanvas(_ model: CanvasItemModel) -> Bool {
        activedCanvas?.id == model.id
    }
    
        
    func dragModify(_ value: DragGesture.Value) {
        guard let activedCanvas = activedCanvas else { return }

        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2

        let canvasWidth = screenWidth * 0.68
        let canvasHeight = screenHeight * 0.63
        let halfCanvasWidth = canvasWidth / 2
        let halfCanvasHeight = canvasHeight / 2

        if let index = selectedCanvas.firstIndex(where: { $0.id == activedCanvas.id }) {
            var newX = value.location.x
            var newY = value.location.y

            let canvasCenterX = centerX + (screenWidth * -0.05)
            let canvasCenterY = centerY + (screenHeight * -0.1)

            let minX = canvasCenterX - halfCanvasWidth + (activedCanvas.size.width / 2)
            let maxX = canvasCenterX + halfCanvasWidth - (activedCanvas.size.width / 2)
            let minY = canvasCenterY - halfCanvasHeight + (activedCanvas.size.height / 2)
            let maxY = canvasCenterY + halfCanvasHeight - (activedCanvas.size.height / 2)

            newX = max(minX, min(newX, maxX))
            newY = max(minY, min(newY, maxY))

            selectedCanvas[index].position = CGPoint(x: newX, y: newY)

            self.activedCanvas = selectedCanvas[index]
        }
    }

    func controlCanvasItemEdge() -> AlignmentType {
        guard let controlCanvas = activedCanvas else { return .none }
        
        let alignmentThreshold: CGFloat = 2.0
        
        let filteredCanvas = selectedCanvas.filter { $0.id != controlCanvas.id }
        
        var alignment: AlignmentType = .none
        
        for item in filteredCanvas {
            let horizontalAlignment = abs(item.position.y - controlCanvas.position.y) < alignmentThreshold
            let verticalAlignment = abs(item.position.x - controlCanvas.position.x) < alignmentThreshold
            
            if horizontalAlignment {
                alignment = .horizontal
            }
            
            if verticalAlignment {
                alignment = .vertical
            }
            
            if alignment != .none {
                break
            }
        }
        
        return alignment
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
