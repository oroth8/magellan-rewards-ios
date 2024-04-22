    import UIKit
    import Turbo
    import WebKit

    let image = UIImage(named: "logo")

    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        var window: UIWindow?
        private lazy var navigationController = UINavigationController()
        private lazy var session = makeSession()
        private lazy var modalSession = makeSession()

        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            self.window = UIWindow(windowScene: windowScene)
            self.window?.rootViewController = UIViewController()
            self.window?.makeKeyAndVisible()
            window!.rootViewController = navigationController
            visit(url: URL(string: "https://www.magellan-rewards.com/rewards")!)
        }
        
        private func visit(url: URL, action: VisitAction = .advance, properties: PathProperties = [:]) {
            let viewController = VisitableViewController(url: url)
            
            navigationController.dismiss(animated: true)
            
            if properties["presentation"] as? String == "modal" {
                   navigationController.present(viewController, animated: true)
               } else if action == .advance {
                   navigationController.pushViewController(viewController, animated: true)
               }
            
            if properties["presentation"] as? String == "modal" {
                modalSession.visit(viewController)
            } else {
                session.visit(viewController)
            }
        }
        
        private func makeSession() -> Session {
               let configuration = WKWebViewConfiguration()
               configuration.applicationNameForUserAgent = "MagellanRewardsMobile"
               let session = Session(webViewConfiguration: configuration)
               session.delegate = self
               let pathConfiguration = PathConfiguration(sources: [
                 .file(Bundle.main.url(forResource: "PathConfiguration", withExtension: "json")!)
               ])

               session.pathConfiguration = pathConfiguration
               return session
           }
        
    }

    extension SceneDelegate: SessionDelegate {
        func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
            visit(url: proposal.url, action: proposal.options.action, properties: proposal.properties)
        }
        
        func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
            print("didFailRequestForVisitable: \(error)")
        }
        
        func sessionWebViewProcessDidTerminate(_ session: Session) {
            session.reload()
        }
    }
