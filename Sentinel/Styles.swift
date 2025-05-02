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

struct GridTemplateView: View {
    @EnvironmentObject var appState: AppState
    let delegate: DropDelegate
    let types: [UTType]
    let quarantine: Bool

    var empty: Bool {
        quarantine ? appState.quarantineAppName == nil : appState.signAppName == nil
    }

    var body: some View {
        ZStack(alignment: .center) {
            // Base rounded rectangle background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 200/255, green: 224/255, blue: 229/255, opacity: 0.6))

            GeometryReader { geo in
                let color = Color.white.opacity(0.5)
                let size = geo.size
                let gridCount = 6
                let spacing = size.width / CGFloat(gridCount)
                let squareSize = spacing * CGFloat(gridCount - 1) * 0.80
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                ZStack {
                    // Grid lines
                    Path { path in
                        for i in 0...gridCount {
                            let offset = CGFloat(i) * spacing
                            path.move(to: CGPoint(x: offset, y: 0))
                            path.addLine(to: CGPoint(x: offset, y: size.height))
                            path.move(to: CGPoint(x: 0, y: offset))
                            path.addLine(to: CGPoint(x: size.width, y: offset))
                        }
                    }
                    .stroke(color, lineWidth: 1)

                    // Square
                    Path { path in
                        let origin = CGPoint(x: center.x - squareSize / 2, y: center.y - squareSize / 2)
                        path.addRect(CGRect(origin: origin, size: CGSize(width: squareSize, height: squareSize)))
                    }
                    .stroke(color, lineWidth: 1)

                    // Circle same size as square
                    Circle()
                        .stroke(color, lineWidth: 1)
                        .frame(width: squareSize, height: squareSize)
                        .position(center)

                    // Smaller center circle
                    Circle()
                        .stroke(color, lineWidth: 1)
                        .frame(width: squareSize / 2, height: squareSize / 2)
                        .position(center)

                    // Diagonal lines
                    Path { path in
                        let topLeft = CGPoint(x: center.x - squareSize / 2, y: center.y - squareSize / 2)
                        let bottomRight = CGPoint(x: center.x + squareSize / 2, y: center.y + squareSize / 2)
                        let topRight = CGPoint(x: center.x + squareSize / 2, y: center.y - squareSize / 2)
                        let bottomLeft = CGPoint(x: center.x - squareSize / 2, y: center.y + squareSize / 2)
                        path.move(to: topLeft)
                        path.addLine(to: bottomRight)
                        path.move(to: topRight)
                        path.addLine(to: bottomLeft)
                    }
                    .stroke(color, lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))

            }

            if empty {
                VectorDropHere()
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 41.30552673339844, height: 37.02809524536133)
            }



        }
        .frame(width: 80, height: 80)
        .padding(.top, 1)
        .overlay {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white, lineWidth: empty ? 5 : 2)
                    .shadow(radius: 1, y: 1)
                if !empty {
                    if quarantine {
                        if appState.quarantineUnlocked {
                            VStack {
                                HStack {
                                    Image(systemName: "lock.open.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color(red: 88/255, green: 86/255, blue: 214/255, opacity: 1))
                                        .bold()
                                        .offset(x: -4, y: -10)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }

                    } else {
                        if appState.signUnlocked {
                            VStack {
                                HStack {
                                    Image(systemName: "lock.open.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color(red: 88/255, green: 86/255, blue: 214/255, opacity: 1))
                                        .bold()
                                        .offset(x: -4, y: -10)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }

                    if let icon = quarantine ? appState.quarantineAppIcon : appState.signAppIcon {
                        Image(nsImage: icon)
                            .resizable()
                            .scaledToFit()
                            .padding(5)
                    }

                }


            }
        }
        .onDrop(of: types, delegate: delegate)
    }
}


struct DropBG: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
//TODO                .background(.ultraThinMaterial)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(1.0))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.secondary.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, dash: [8, 4], dashPhase: 0))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


public struct LearnMorePopover: View {
    @State private var isPopoverPresented: Bool = false
    let text: String
    let prominentText: String

    public var body: some View {
        Button(action: {
            self.isPopoverPresented.toggle()
        }) {
            Text("Learn more...")
                .font(.body)
                .foregroundStyle(.secondary.opacity(0.8))
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .popover(isPresented: $isPopoverPresented , arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 5) {
                Text(text)
                Text(prominentText)
                    .bold()
            }
            .padding()
            .frame(width: 400)
        }
    }
}

struct UnlockView: View {
    let text: String

    var body: some View {
        HStack() {
            Image(systemName: "lock.open.fill")            
            Text(text)
        }
        .foregroundColor(Color(red: 1/255, green: 99/255, blue: 16/255, opacity: 1))
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
