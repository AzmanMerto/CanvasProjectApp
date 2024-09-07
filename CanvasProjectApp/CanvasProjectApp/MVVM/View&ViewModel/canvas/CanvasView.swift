//
//  CanvasView.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 7.09.2024.
//

import SwiftUI

struct CanvasView: View {
    
    @StateObject var viewModel: CanvasViewModel
    
    init(pexelsManager: PexelsManagerProtocol = PexelsManager()) {
        _viewModel = StateObject(wrappedValue: CanvasViewModel(pexelsManager: pexelsManager))
    }
    
    var body: some View {
        VStack {
            headerView
            Spacer()
        }
        .sheet(isPresented: $viewModel.isCanvasShowing) {
            CanvasItemShowcaseView(
                selected: $viewModel.selectedCanvas,
                models: viewModel.fetchedCanvas,
                loadMoreAction: viewModel.loadPhotos
            )
            .modifier(SheetModifier(0.8))
        }
    }
}

#Preview {
    CanvasView()
}

private extension CanvasView {
    var headerView: some View {
        HStack {
            Text("Canvas")
                .foregroundStyle(ColorHandler.makeMainColor(.textColor))
            Spacer()
            Image(systemName: "plus.app.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(ColorHandler.makeMainColor(.buttonColor))
                .frame(width: dw(0.08))
                .onTapGesture { viewModel.openCanvasSheet() }
        }
        .frame(width: dw(), height: dh(consSize: .size05))
        
        .background(ColorHandler.makeMainColor(.backgroundColor).padding(.horizontal, -dw(consSize: .size05)))
    }
}
