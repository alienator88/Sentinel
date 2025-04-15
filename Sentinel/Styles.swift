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
    @Environment(\.controlSize) var controlSize

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let cornerRadius = height / 2
            let iconSize = height * 0.43
            let offsetX = width * 0.22

            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(configuration.isOn ?
                              Color.green.opacity(0.7) :
                                Color.red.opacity(0.7))
                        .frame(width: width, height: height)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .strokeBorder(.primary.opacity(0.2), lineWidth: 1)
                        )


                    HStack {
                        Image(systemName: "lock")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: iconSize, height: iconSize)
                            .padding(.leading, height * 0.25)
                            .opacity(configuration.isOn ? 1 : 0)

                        Spacer()

                        Image(systemName: "lock.open")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: iconSize, height: iconSize)
                            .padding(.trailing, height * 0.20)
                            .opacity(configuration.isOn ? 0 : 1)
                    }
                }
                .frame(width: width, height: height, alignment: .center)

                .overlay(
                    ZStack {
                        Circle()
                            .fill(Color.white)
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        .gray.opacity(0.7),
                                        .gray.opacity(0.1),
                                        .gray.opacity(0.7),
                                        .gray.opacity(0.1),
                                        .gray.opacity(0.7)
                                    ]),
                                    center: .center
                                )
                            )
                    }
                        .shadow(color: .black.opacity(0.3), radius: 1)
                        .padding(4)
                        .offset(x: configuration.isOn ? offsetX : -offsetX)
                )
                .onTapGesture {
                    withAnimation(.spring(duration: 0.5)) {
                        configuration.isOn.toggle()
                    }
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
                .strokeBorder(Color.primary.opacity(0.5), style: StrokeStyle(lineWidth: 0.5, dash: [8, 4], dashPhase: 0))
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



public struct SimpleButtonStyle: ButtonStyle {
    @State private var hovered = false
    let icon: String
    let iconFlip: String
    let label: String
    let help: String
    let color: Color
    let size: CGFloat
    let padding: CGFloat
    let rotate: Bool

    public init(icon: String, iconFlip: String = "", label: String = "", help: String, color: Color = .primary, size: CGFloat = 20, padding: CGFloat = 5, rotate: Bool = false) {
        self.icon = icon
        self.iconFlip = iconFlip
        self.label = label
        self.help = help
        self.color = color
        self.size = size
        self.padding = padding
        self.rotate = rotate
    }

    public func makeBody(configuration: Self.Configuration) -> some View {
        HStack(alignment: .center) {
            Image(systemName: (hovered && !iconFlip.isEmpty) ? iconFlip : icon)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
            //                .scaleEffect(hovered ? 1.05 : 1.0)
                .rotationEffect(.degrees(rotate ? (hovered ? 90 : 0) : 0))
                .animation(.easeInOut(duration: 0.2), value: hovered)
            if !label.isEmpty {
                Text(label)
            }
        }
        .foregroundColor(hovered ? color.opacity(0.5) : color)
        .padding(padding)
        .onHover { hovering in
            withAnimation() {
                hovered = hovering
            }
        }
        .scaleEffect(configuration.isPressed ? 0.90 : 1)
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
