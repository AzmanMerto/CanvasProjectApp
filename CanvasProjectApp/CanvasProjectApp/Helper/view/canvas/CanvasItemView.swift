//
//  CanvasItemView.swift
//  CanvasProjectApp
//
//  Created by Mert Türedü on 8.09.2024.
//

import SwiftUI

struct CanvasItemView: View {
    
    @Binding var activedCanvas: CanvasItemModel?
    @State private var isDragging: Bool = false
    let model: CanvasItemModel
    let touchEdgeType: AlignmentType
    let isSelected: Bool
    let dragingValue: (DragGesture.Value) -> ()
    let active: () -> ()
    
    init(activedCanvas: Binding<CanvasItemModel?>,
         model: CanvasItemModel,
         touchEdgeType: AlignmentType,
         isSelected: Bool,
         dragingValue: @escaping (DragGesture.Value) -> (),
         active: @escaping () -> ()) {
        _activedCanvas = activedCanvas
        self.model = model
        self.touchEdgeType = touchEdgeType
        self.dragingValue = dragingValue
        self.isSelected = isSelected
        self.active = active
    }
    
    var body: some View {
        ZStack {
            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: dw(model.size.width), height: dh(model.size.height))
                    .position(x: model.position.x, y: model.position.y)
                    .opacity(isSelected ? 0.7 : 1)
                    .overlay { lineView }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragingValue(value)
                                isDragging = true
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                    .onTapGesture { active() }
            }
        }
    }
}


#Preview {
    CanvasItemView(activedCanvas: .constant(nil), 
                   model: canvasItem1,
                   touchEdgeType: .none,
                   isSelected: false) { _ in } active: { }

}

extension CanvasItemView {
    @ViewBuilder
    private var lineView: some View {
        if isDragging {
            if touchEdgeType == .horizontal {
                Rectangle()
                    .frame(width: dw(), height: 2)
                    .foregroundStyle(ColorHandler.makeMainColor(.lineColor))
                    .position(x: dw() / 2, y: model.position.y + dh(model.size.height / 1.9))
            }
            if touchEdgeType == .vertical {
                Rectangle()
                    .frame(width: 2, height: dh(0.8))
                    .foregroundStyle(ColorHandler.makeMainColor(.lineColor))
                    .position(x: model.position.x + dw(model.size.width) / 2, y: dh() / 2.25)
            }
        }
    }
    
}
