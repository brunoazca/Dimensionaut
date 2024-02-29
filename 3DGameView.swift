import SwiftUI

struct ThreeDGameView: View {
    @ObservedObject var appRouter: AppRouter
    var body: some View {
        GeometryReader { geo in
            ThreeDViewControllerRepresentable(size: geo.size, appRouter: appRouter)
        }.ignoresSafeArea()
        
    }
}
#Preview {
    ThreeDGameView(appRouter: AppRouter())
}
