//
//  Toggle.swift
//  Sentinel
//
//  Created by Alin Lupascu on 3/24/23.
//

import SwiftUI

struct MyToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        HStack {
            
            ZStack{
                RoundedRectangle(cornerRadius: 50)
                    .fill(backgroundStyle(forConfiguration: configuration))
                    .frame(width: 100, height: 60)
                HStack{
                    Image(systemName: "lock.shield")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .padding(.leading, 10)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "shield.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .padding(.trailing, 10)
                        .foregroundColor(.white)
                }
                
            }
            .frame(width: 100, height: 60, alignment: .center)
            .overlay(
                Circle()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 0)
                    .padding(.all, 4)
                    .offset(x: configuration.isOn ? 20 : -20, y: 0)
            )
            .overlay(
                Image(systemName: "power")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black.opacity(0.3))
                    .offset(x: configuration.isOn ? 20 : -20, y: 0)
            )
            .onTapGesture {
                withAnimation(.linear(duration: 0.3)) {
                    configuration.isOn.toggle()
                }
            }
        }
        
        
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
//private let greenBG: AnyShapeStyle = AnyShapeStyle(
//    .green.shadow(.inner(radius: 2, x: 0, y: 1))
//)
//
//private let redBG: AnyShapeStyle = AnyShapeStyle(
//    .red.shadow(.inner(radius: 2, x: 0, y: 1))
//)


