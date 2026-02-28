import Foundation

// MARK: - APIError
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case authenticationError
    case serverError(String)
    case rateLimitExceeded
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return error.localizedDescription
        case .authenticationError:
            return "Authentication failed"
        case .serverError(let message):
            return message
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .timeout:
            return "Request timed out"
        }
    }
}

// MARK: - APIService
/// Production-ready API service for Instant Link backend
actor APIService {
    
    // MARK: - Properties
    static let shared = APIService()
    
    private let baseURL: String
    private let session: URLSession
    private var authToken: String?
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Configuration
    enum Environment {
        case development
        case staging
        case production
        
        var baseURL: String {
            switch self {
            case .development:
                return "http://localhost:5000/api"
            case .staging:
                return "https://staging-api.instantlink.io/api"
            case .production:
                return "https://api.instantlink.io/api"
            }
        }
    }
    
    // MARK: - Initialization
    init(environment: Environment = .development) {
        self.baseURL = environment.baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.httpShouldSetCookies = true
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Authentication
    func setAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    func getAuthToken() -> String? {
        return authToken
    }
    
    // MARK: - Auth Endpoints
    
    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        let endpoint = "\(baseURL)/auth/register"
        let body = RegisterRequest(username: username, email: email, password: password)
        return try await post(endpoint, body: body)
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "\(baseURL)/auth/login"
        let body = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await post(endpoint, body: body)
        
        if let token = response.token {
            await setAuthToken(token)
        }
        
        return response
    }
    
    func logout() async throws {
        let endpoint = "\(baseURL)/auth/logout"
        _ = try await post(endpoint, body: EmptyRequest())
        await setAuthToken(nil)
    }
    
    func refreshToken() async throws -> AuthResponse {
        let endpoint = "\(baseURL)/auth/refresh"
        return try await post(endpoint, body: EmptyRequest())
    }
    
    // MARK: - Message Endpoints
    
    func fetchMessages(page: Int = 1, perPage: Int = 20) async throws -> PaginatedResponse<Message> {
        let endpoint = "\(baseURL)/messages?page=\(page)&per_page=\(perPage)"
        return try await get(endpoint)
    }
    
    func fetchMessage(id: String) async throws -> Message {
        let endpoint = "\(baseURL)/messages/\(id)"
        return try await get(endpoint)
    }
    
    func createMessage(url: String, title: String, description: String) async throws -> Message {
        let endpoint = "\(baseURL)/messages"
        let body = CreateMessageRequest(url: url, title: title, description: description)
        return try await post(endpoint, body: body)
    }
    
    func updateMessage(_ message: Message) async throws -> Message {
        let endpoint = "\(baseURL)/messages/\(message.id)"
        let body = UpdateMessageRequest(
            title: message.title,
            description: message.description
        )
        return try await put(endpoint, body: body)
    }
    
    func deleteMessage(id: String) async throws {
        let endpoint = "\(baseURL)/messages/\(id)"
        _ = try await delete(endpoint)
    }
    
    func searchMessages(query: String, page: Int = 1) async throws -> PaginatedResponse<Message> {
        let endpoint = "\(baseURL)/messages/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(page)"
        return try await get(endpoint)
    }
    
    // MARK: - User Endpoints
    
    func getCurrentUser() async throws -> User {
        let endpoint = "\(baseURL)/users/me"
        return try await get(endpoint)
    }
    
    func updateUser(username: String?, displayName: String?) async throws -> User {
        let endpoint = "\(baseURL)/users/me"
        let body = UpdateUserRequest(username: username, displayName: displayName)
        return try await put(endpoint, body: body)
    }
    
    func fetchUser(id: String) async throws -> User {
        let endpoint = "\(baseURL)/users/\(id)"
        return try await get(endpoint)
    }
    
    // MARK: - Link Preview Endpoints
    
    func fetchLinkPreview(url: String) async throws -> LinkPreview {
        let endpoint = "\(baseURL)/preview?url=\(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        return try await get(endpoint)
    }
    
    // MARK: - Helper Methods
    
    private func request<T: Decodable>(_ url: String, method: String, body: Encodable? = nil) async throws -> T {
        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.decodingError(error)
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return try decoder.decode(T.self, from: data)
        case 204:
            // No content
            throw APIError.invalidResponse
        case 401:
            throw APIError.authenticationError
        case 429:
            throw APIError.rateLimitExceeded
        case 500..<600:
            throw APIError.serverError("Server error: \(httpResponse.statusCode)")
        default:
            do {
                let errorResponse = try decoder.decode(APIErrorResponse.self, from: data)
                throw APIError.serverError(errorResponse.message ?? "Unknown error")
            } catch {
                throw APIError.serverError("HTTP \(httpResponse.statusCode)")
            }
        }
    }
    
    private func post<T: Decodable>(_ url: String, body: Encodable) async throws -> T {
        return try await request(url, method: "POST", body: body)
    }
    
    private func get<T: Decodable>(_ url: String) async throws -> T {
        return try await request(url, method: "GET", body: nil)
    }
    
    private func put<T: Decodable>(_ url: String, body: Encodable) async throws -> T {
        return try await request(url, method: "PUT", body: body)
    }
    
    private func delete<T: Decodable>(_ url: String) async throws -> T {
        return try await request(url, method: "DELETE", body: nil)
    }
}

// MARK: - Request Models

struct EmptyRequest: Encodable {}

struct RegisterRequest: Encodable {
    let username: String
    let email: String
    let password: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct CreateMessageRequest: Encodable {
    let url: String
    let title: String
    let description: String
}

struct UpdateMessageRequest: Encodable {
    let title: String
    let description: String
}

struct UpdateUserRequest: Encodable {
    let username: String?
    let displayName: String?
}

// MARK: - Response Models

struct AuthResponse: Codable {
    let user: User
    let token: String?
    let refreshToken: String?
}

struct APIErrorResponse: Codable {
    let message: String?
    let code: String?
    let errors: [ValidationError]?
}

struct ValidationError: Codable {
    let field: String
    let message: String
}
