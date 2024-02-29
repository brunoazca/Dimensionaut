import SwiftUI

struct ContentView: View {
    @StateObject var appRouter: AppRouter = AppRouter()
    var body: some View {
        ZStack{
            switch appRouter.router {
            case .startView:
                StartView(appRouter: appRouter)
            case .introView:
                IntroView(appRouter: appRouter)
            case .blockGameView:
                BlockGameView(appRouter: appRouter)
            case .twoDGameView:
                TwoDGameView(appRouter: appRouter)
            case .oneDTutorialView:
                OneDTutorialView(appRouter: appRouter)
            case .twoDTutorialView:
                TwoDTutorialView(appRouter: appRouter)
            case .threeDTutorialView:
                ThreeDTutorialView(appRouter: appRouter)
            case .threeDGameView:
                ThreeDGameView(appRouter: appRouter)
            case .finalView:
                FinalView(appRouter: appRouter)
            case .gameEnd:
                GameEnd(appRouter: appRouter)
            }
        }.animation(.linear, value: appRouter.router)
    }
}
enum Router{
    case startView
    case introView
    case blockGameView
    case twoDGameView
    case oneDTutorialView
    case twoDTutorialView
    case threeDTutorialView
    case threeDGameView
    case finalView
    case gameEnd
}

class AppRouter: ObservableObject {
    @Published var router: Router = .startView
}


