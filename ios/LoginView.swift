import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var onLogin: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Login")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: handleLogin) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Login")
                            }
                            Spacer()
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                }
                
                Section {
                    NavigationLink("Create Account", destination: SignUpView())
                }
            }
            .navigationTitle("Instant Link")
        }
    }
    
    private func handleLogin() {
        isLoading = true
        errorMessage = ""
        
        // TODO: Connect to backend API
        // APIService.shared.login(email: email, password: password) { result in
        //     switch result {
        //     case .success:
        //         onLogin()
        //     case .failure(let error):
        //         errorMessage = error.localizedDescription
        //     }
        //     isLoading = false
        // }
        
        // Mock login for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            onLogin()
        }
    }
}

#Preview {
    LoginView(onLogin: {})
}
