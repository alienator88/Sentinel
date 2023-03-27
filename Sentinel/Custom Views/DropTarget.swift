import SwiftUI
import UniformTypeIdentifiers

struct DropTarget: View {
    
    let delegate: DropDelegate
    
    let types: [UTType]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("bg").opacity(1))
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color("drop").opacity(0.5), style: StrokeStyle(lineWidth: 0.5, dash: [8, 4], dashPhase: 0))
//                .strokeBorder(Color("stroke").opacity(1), style: StrokeStyle(lineWidth: 1, dashPhase: 0))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onDrop(of: types, delegate: delegate)
    }
}

