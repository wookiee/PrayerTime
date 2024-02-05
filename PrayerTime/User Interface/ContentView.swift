
import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    
    @StateObject var vm = ContentViewModel()
    @EnvironmentObject var sizeModel: WindowSizeModel
    
    var primaryText: some View {
        Text(vm.primaryContent)
            .font(.largeTitle)
            .fixedSize()
    }
    
    var secondaryText: some View {
        Text(vm.secondaryContent)
            .font(.headline)
            .fixedSize()
    }
    
    var body: some View {
        VStack(alignment: .center) {
            primaryText
            secondaryText
        }
        .padding()
        .background(GeometryReader { geometry in
            Color.clear
                .onAppear {
                    sizeModel.size = geometry.size
                }
        })
    }
    
    
}

#Preview {
    ContentView()
}
