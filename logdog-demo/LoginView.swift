//
//  LoginView.swift
//  logdog-demo
//
//  Created by kelvinfok on 4/8/25.
//
import SwiftUI
import LogDog

/*
 Common Issues Faced During Testing & Debugging

 A. QA encounters a bug during testing, but is unable to reproduce it later.
 B. A feature appears broken to QA, but works as expected on the developer’s machine.
 C. Designers report UI issues like text being cut off or overflowing.
 D. QA struggles to identify or describe the exact screen or flow where a bug occurs.

 Tools & Solutions to Address These Challenges
   1.  Remote Logging – Capture device logs from real user sessions to investigate non-reproducible issues.
   2.  Network Monitoring – Track and inspect HTTP requests/responses to detect backend/API inconsistencies.
   3.  API Mocking – Simulate specific responses or error conditions for consistent testing.
   4.  Remote Screenshots – Capture the visual state of the app during a test to help pinpoint UI or flow issues.
 */

struct LoginTextResponse: Decodable {
  let title: String
  let caption: String
}

@MainActor
class LoginViewModel: ObservableObject {
  @Published var loginText = LoginTextResponse(title: "", caption: "")
  @Published var isTextLoading = true
  
  @Published var username = ""
  @Published var password = ""
  @Published var isLoggingIn = false
  @Published var loginStatus: String?
  
  var logoURL: URL? { URL(string: "https://logos-world.net/wp-content/uploads/2020/04/Nike-Logo.png") }
  
  let logger = LogDogLogger(subsystem: "com.yourcompany.myapp", category: "login_page")

  var canLogin: Bool {
    !username.isEmpty && !password.isEmpty && !isLoggingIn
  }

  func fetchLoginText() async {
    guard let url = URL(string: "https://www.jsonkeeper.com/b/N97QM") else { return }
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let decoded = try JSONDecoder().decode(LoginTextResponse.self, from: data)
      self.loginText = decoded
    } catch {
      print("Failed to load login text:", error)
    }
    isTextLoading = false
  }

  func login() {
    isLoggingIn = true
    loginStatus = nil
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
      if self.username.lowercased() == "admin" && self.password == "password" {
        self.loginStatus = "Login successful ✅"
        self.logger.l("Login successful for user: \(self.username)")
      } else {
        self.loginStatus = "Invalid username or password"
        self.logger.e("Login failed for user: \(self.username)")
      }
      self.isLoggingIn = false
    }
  }
}

struct LoginView: View {
  @StateObject private var viewModel = LoginViewModel()
  @State private var isShown = false

  var body: some View {
    VStack(spacing: 32) {
      logo()
      header()
      form()
      loginButton()
      statusView()
      Spacer()
    }
    .padding()
    .logDogSheet(isShown: $isShown)
    .onAppear {
      LogDog.i("LoginView appeared")
      Task {
        await viewModel.fetchLoginText()
      }
    }
  }
  
  @ViewBuilder
  private func logo() -> some View {
    if let url = viewModel.logoURL {
      AsyncImage(url: url) { phase in
        switch phase {
        case .empty:
          ProgressView()
        case .success(let image):
          image
            .resizable()
            .scaledToFit()
            .frame(height: 100)
            .padding(.top)
        case .failure:
          Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(height: 100)
            .foregroundColor(.gray)
        @unknown default:
          EmptyView()
        }
      }
    }
  }
  
  @ViewBuilder
  private func header() -> some View {
    VStack(spacing: 6) {
      if viewModel.isTextLoading {
        ProgressView()
      } else {
        Text(viewModel.loginText.title)
          .font(.title)
          .fontWeight(.bold)

        Text(viewModel.loginText.caption)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
    }
  }
  
  @ViewBuilder
  private func form() -> some View {
    VStack(spacing: 16) {
      CustomTextField(title: "Username", text: $viewModel.username)
      CustomSecureField(title: "Password", text: $viewModel.password)
    }
  }
  
  @ViewBuilder
  private func loginButton() -> some View {
    Button(action: {
      viewModel.login()
    }) {
      HStack {
        if viewModel.isLoggingIn {
          ProgressView()
        } else {
          Text("Log In")
            .fontWeight(.semibold)
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.canLogin ? Color.accentColor : Color.gray.opacity(0.5))
      .foregroundColor(.white)
      .cornerRadius(12)
      .animation(.easeInOut(duration: 0.2), value: viewModel.isLoggingIn)
    }
    .disabled(!viewModel.canLogin)

    Button("Show LogDog Sheet") {
      isShown = true
    }
  }
  
  @ViewBuilder
  private func statusView() -> some View {
    if let status = viewModel.loginStatus {
      Text(status)
        .foregroundColor(status.contains("success") ? .green : .red)
        .font(.footnote)
        .transition(.opacity)
    }
  }
}

#Preview {
  LoginView()
}
