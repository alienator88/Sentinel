import SwiftUI

struct AboutView: View {
    
    let icon: NSImage
    let name: String
    let version: String
    let build: String
    let developerName: String
    @State private var revealDetails = true

    var body: some View {

        VStack {
            HStack(alignment: .top) {
                Image(nsImage: icon)
                    .padding()
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(name)
                            .font(.title)
                            .bold()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Spacer()
                        HStack {
                            Text("v\(version)")
                            Text(" (build \(build))")
                        }
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [.purple, .pink, .orange],
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        )
                        
                        
                    }
                    Divider()
                        .padding(.top, -8)
                    HStack{
                        Text("Developed by:")
                            .bold()
                            .padding(.bottom, 2)
                        Text(developerName)
                            .padding(.bottom, 2)
                    }
                    
                    
                    DisclosureGroup(isExpanded: $revealDetails)
                    {
                        List
                        {
                            HStack{
                                VStack(alignment: .leading){
                                    Text("Wynioux")
                                    Text("macOS-GateKeeper-Helper").font(.footnote)
                                }
                                Spacer()
                                Button
                                {
                                    NSWorkspace.shared.open(URL(string: "https://github.com/wynioux/macOS-GateKeeper-Helper")!)
                                } label: {
                                    Label("Site", systemImage: "paperplane")
                                }
                            }
                            
                            HStack{
                                VStack(alignment: .leading){
                                    Text("App Icon")
                                    Text("Freepik.com").font(.footnote)
                                }
                                Spacer()
                                Button
                                {
                                    NSWorkspace.shared.open(URL(string: "https://www.freepik.com/free-vector/classic-spartan-helmet-with-gradient-style_3272693.htm")!)
                                } label: {
                                    Label("Site", systemImage: "paperplane")
                                }
                            }
                            
                        }
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            idealHeight: 80
                        )
                    } label: {
                        Text("Acknowledgements")
                    }
                    
                    
                    Spacer()

                }
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 30))
            }
            HStack {
                Spacer()
                Button
                {
                    NSWorkspace.shared.open(URL(string: "https://github.com/alienator88/Sentinel")!)
                } label: {
                    Label("GitHub", systemImage: "ellipsis.curlybraces")
                }
                .padding(.bottom, 30)
                .padding(.trailing, 20)
            }
        }
    }
}
