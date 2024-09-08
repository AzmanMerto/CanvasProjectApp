//
//  CanvasItemShowcaseView.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import SwiftUI

struct CanvasItemShowcaseView: View {
    
    @Binding var selectedItems: [CanvasItemModel]
    let models: [CanvasItemModel]
    var loadMoreAction: () -> Void 

    init(selected selectedItems: Binding<[CanvasItemModel]>,
         models: [CanvasItemModel],
         loadMoreAction: @escaping () -> Void) {
        _selectedItems = selectedItems
        self.models = models
        self.loadMoreAction = loadMoreAction
    }
    
    var body: some View {
        VStack {
            headerView
            ScrollView(.vertical) {
                itemsView
            }
        }
        .background(ColorHandler.makeMainColor(.backgroundColor))
    }
}

#Preview {
    CanvasItemShowcaseView(selected: .constant([]), models: [canvasItem1, canvasItem2, canvasItem3, canvasItem4Empty, canvasItem5Empty], loadMoreAction: {})
}

private extension CanvasItemShowcaseView {
    var headerView: some View {
        HStack {
            Text("Your Canvas")
                .foregroundStyle(ColorHandler.makeMainColor(.textColor))
                .font(FontHandler.makeFont(.system16))
        }
        .padding(.vertical)
    }
    
    var itemsView: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        
        return LazyVGrid(columns: columns) {
            ForEach(models.indices, id: \.self) { index in
                let model = models[index]
                
                if !selectedItems.contains(where: { $0.id == model.id }) {
                    makeItemImageView(model)
                        .frame(width: dw(model.size.width), height: dh(model.size.height))
                        .onAppear {
                            if index == models.count - 1 {
                                loadMoreAction()
                            }
                        }
                }
            }
        }
        .animation(.easeIn, value: models.count)
    }
}

private extension CanvasItemShowcaseView {
    @ViewBuilder
    func makeItemImageView(_ model: CanvasItemModel) -> some View {
        if let image = model.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .onTapGesture { addItemModel(model) }
                
        } else {
            ProgressView()
                .tint(ColorHandler.makeMainColor(.textColor))
        }
    }
    
    func addItemModel(_ model: CanvasItemModel) {
        print("Added model id is \(model.id)")
        withAnimation(.linear) { selectedItems.append(model)  }
    }
}
