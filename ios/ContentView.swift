import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                HomeView()
            } else {
                LoginView(onLogin: { isAuthenticated = true })
            }
        }
    }
}

#Preview {
    ContentView()
}
