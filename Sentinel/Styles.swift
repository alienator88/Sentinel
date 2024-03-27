//
//  Styles.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/26/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers


struct RedGreenShield: ToggleStyle {

    func makeBody(configuration: Configuration) -> some View {

        HStack {

            ZStack{
                RoundedRectangle(cornerRadius: 50)
                    .fill(backgroundStyle(forConfiguration: configuration))
                    .frame(width: 100, height: 60)
                    .shadow(color: Color("mode").opacity(0.3), radius: 3, x: 0, y: 0)
                HStack{
                    Image(systemName: "lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 14)
                        .foregroundColor(.white)
                        .opacity(configuration.isOn ? 1 : 0)
                    Spacer()
                    Image(systemName: "lock.open")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .padding(.trailing, 10)
                        .foregroundColor(.white)
                        .opacity(configuration.isOn ? 0 : 1)
                }

            }
            .frame(width: 100, height: 60, alignment: .center)
            .overlay(
                Circle()
                    .padding(2)
                    .foregroundColor(.white).opacity(0.8)
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 0)
                    .padding(.all, 4)
                    .offset(x: configuration.isOn ? 20 : -20, y: 0)
            )
            .overlay(
                Image(systemName: "power")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black.opacity(0.7))
                    .offset(x: configuration.isOn ? 20 : -20, y: 0)
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.7)) {
                    configuration.isOn.toggle()
                }
            }
        }


    }

}



struct DropTarget: View {

    let delegate: DropDelegate

    let types: [UTType]

    var body: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color("bg").opacity(1))
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color("drop").opacity(0.5), style: StrokeStyle(lineWidth: 0.5, dash: [8, 4], dashPhase: 0))
            //                .strokeBorder(Color("stroke").opacity(1), style: StrokeStyle(lineWidth: 1, dashPhase: 0))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onDrop(of: types, delegate: delegate)
    }
}



func backgroundStyle(forConfiguration configuration: ToggleStyleConfiguration) -> AnyShapeStyle {
    if #available(macOS 13.0, *) {
        return AnyShapeStyle(
            configuration.isOn ?
            AnyShapeStyle(.green).shadow(.inner(radius: 2, x: 0, y: 1)) :
                AnyShapeStyle(.red).shadow(.inner(radius: 2, x: 0, y: 1))
        )
    } else {
        return AnyShapeStyle(
            configuration.isOn ?
            AnyShapeStyle(.green) :
                AnyShapeStyle(.red
                             )
        )
    }
}



struct SimpleButtonStyle: ButtonStyle {
    @State private var hovered = false
    let icon: String
    let label: String?
    let help: String
    let color: Color

    init(icon: String, label: String? = "", help: String, color: Color) {
        self.icon = icon
        self.label = label
        self.help = help
        self.color = color
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20)
            if let label = label, !label.isEmpty {
                Text(label)
            }
        }
        .foregroundColor(hovered ? color : color.opacity(0.5))
        .padding(5)
        .onHover { hovering in
            withAnimation() {
                hovered = hovering
            }
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .help(help)
    }
}

struct SimpleButtonBrightStyle: ButtonStyle {
    @State private var hovered = false
    let icon: String
    let help: String
    let color: Color
    let shield: Bool?

    init(icon: String, help: String, color: Color, shield: Bool? = nil) {
        self.icon = icon
        self.help = help
        self.color = color
        self.shield = shield
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20)
                .foregroundColor(hovered ? color.opacity(0.5) : color)
        }
        .padding(5)
        .onHover { hovering in
            withAnimation() {
                hovered = hovering
            }
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .help(help)
    }
}


struct LabeledDivider: View {
    let label: String
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.2))

            Text(label)
                .textCase(.uppercase)
                .font(.title2)
                .foregroundColor(.gray.opacity(0.6))
                .padding(.horizontal, 10)
                .frame(minWidth: 80)

            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.2))
        }
        .frame(minHeight: 35)
    }
}
