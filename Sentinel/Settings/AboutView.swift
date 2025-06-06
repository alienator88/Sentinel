import SwiftUI

struct AboutView: View {
    
    var body: some View {

        VStack(alignment: .center) {

            Spacer()

            VStack(spacing: 10) {
                Image(nsImage: NSApp.applicationIconImage)
                Text(Bundle.main.name)
                    .font(.title)
                    .bold()
                HStack {
                    Text("Version \(Bundle.main.version)")
                    Text("(Build \(Bundle.main.buildVersion))").font(.footnote)
                }

                Text("Made with ❤️ by Alin Lupascu").font(.caption)
                Text("With UI/UX contributions from Roman Roan").font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical)

            HStack {
                Spacer()
                Button(action: {
                    NSWorkspace.shared.open(URL(string: "https://github.com/sponsors/alienator88")!)
                }, label: {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "heart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.pink)

                        Text("Sponsor")
                            .font(.body)
                            .bold()
                    }
                    .padding(5)
                })
                Spacer()
            }

            Spacer()

            GroupBox {
                HStack{

                    Text("Submit a bug or feature request")
                        .font(.callout)
                        .foregroundStyle(.primary)
                        .padding(.leading, 5)
                    Spacer()
                    Button {
                        NSWorkspace.shared.open(URL(string: "https://github.com/alienator88/Sentinel/issues/new/choose")!)
                    } label: {
                        Text("Open")
                    }
                        .buttonStyle(.bordered)
                }
                .padding(5)
            }

            Spacer()

        }
    }
}
