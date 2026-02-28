import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case authenticationError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .networkError(let error): return error.localizedDescription
        case .decodingError(let error): return error.localizedDescription
        case .authenticationError: return "Authentication failed"
        case .serverError(let message): return message
        }
    }
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:5000/api" // TODO: Change to production URL
    private let session: URLSession
    private var authToken: String?
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)
    }
    
    func setAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    // MARK: - Auth Endpoints
    
    func register(email: String, password: String, name: String) async throws -> AuthResponse {
        let endpoint = "\(baseURL)/auth/register"
        let body: [String: String] = [
            "email": email,
            "password": password,
            "name": name
        ]
        return try await post(endpoint, body: body)
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "\(baseURL)/auth/login"
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        let response: AuthResponse = try await post(endpoint, body: body)
        if let token = response.token {
            setAuthToken(token)
        }
        return response
    }
    
    func logout() async throws {
        let endpoint = "\(baseURL)/auth/logout"
        _ = try await post(endpoint, body: [:])
        setAuthToken(nil)
    }
    
    // MARK: - Helper Methods
    
    private func request<T: Decodable>(_ url: String, method: String, body: [String: Any]?) async throws -> T {
        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return try JSONDecoder().decode(T.self, from: data)
        case 401:
            throw APIError.authenticationError
        default:
            let error = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw APIError.serverError(error?.error ?? "Unknown error")
        }
    }
    
    private func post<T: Decodable>(_ url: String, body: [String: Any]) async throws -> T {
        return try await request(url, method: "POST", body: body)
    }
    
    private func get<T: Decodable>(_ url: String) async throws -> T {
        return try await request(url, method: "GET", body: nil)
    }
}

// MARK: - Models

struct AuthResponse: Codable {
    let user: User
    let token: String?
}

struct User: Codable {
    let id: String
    let email: String
    let name: String
}

struct APIErrorResponse: Codable {
    let error: String
}
