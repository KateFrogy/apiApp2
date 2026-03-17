
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Show dic from deepSeek") {
                    DicView()
                }
                NavigationLink("Show smth from me") {
                    SmView()
                }
            }
        }
    }
}
