import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var isAuthenticated = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MatchesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Matches")
                }
                .tag(0)
            
            ConversationsView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Messages")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(2)
        }
    }
}

struct MatchesView: View {
    var body: some View {
        NavigationView {
            List {
                Text("Loading matches...")
            }
            .navigationTitle("Discover")
        }
    }
}

struct ConversationsView: View {
    var body: some View {
        NavigationView {
            List {
                Text("No conversations yet")
            }
            .navigationTitle("Messages")
        }
    }
}

struct ProfileView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Profile")) {
                    HStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                        VStack(alignment: .leading) {
                            Text("Your Name")
                                .font(.headline)
                            Text("your.email@example.com")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    Button(action: { isAuthenticated = false }) {
                        HStack {
                            Spacer()
                            Text("Logout")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    HomeView()
}
