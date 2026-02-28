import Foundation
import UIKit

// MARK: - LinkPreviewServiceError
enum LinkPreviewServiceError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case parsingError
    case noMetadataFound
    case cachedDataExpired
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parsingError:
            return "Failed to parse link preview data"
        case .noMetadataFound:
            return "No metadata found for the provided URL"
        case .cachedDataExpired:
            return "Cached data has expired"
        }
    }
}

// MARK: - LinkPreviewService
/// Service for fetching OpenGraph metadata and generating link previews
actor LinkPreviewService {
    
    // MARK: - Properties
    private let session: URLSession
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    private var cachedPreviews: [String: CachedPreview] = [:]
    
    private struct CachedPreview {
        let preview: LinkPreview
        let timestamp: Date
    }
    
    // MARK: - Singleton
    static let shared = LinkPreviewService()
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    /// Fetches OpenGraph metadata for a given URL
    func fetchPreview(for url: String) async throws -> LinkPreview {
        guard let validURL = URL(string: url) else {
            throw LinkPreviewServiceError.invalidURL
        }
        
        // Check cache first
        if let cached = getCachedPreview(for: url) {
            return cached
        }
        
        // Fetch from network
        let preview = try await fetchFromNetwork(url: validURL)
        
        // Cache the result
        cachePreview(preview, for: url)
        
        return preview
    }
    
    /// Prefetches previews for multiple URLs
    func prefetchPreviews(for urls: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    do {
                        _ = try await self.fetchPreview(for: url)
                    } catch {
                        print("Prefetch error for \(url): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Clears all cached previews
    func clearCache() {
        cachedPreviews.removeAll()
    }
    
    // MARK: - Private Methods
    private func fetchFromNetwork(url: URL) async throws -> LinkPreview {
        // Try fetching from backend API first
        do {
            return try await fetchFromAPI(url: url)
        } catch {
            print("API fetch failed, falling back to direct scraping: \(error)")
        }
        
        // Fallback: Direct OpenGraph scraping
        return try await scrapeOpenGraph(url: url)
    }
    
    private func fetchFromAPI(url: URL) async throws -> LinkPreview {
        let apiEndpoint = "https://api.instantlink.io/v1/preview?url=\(url.absoluteString)"
        
        guard let apiURL = URL(string: apiEndpoint) else {
            throw LinkPreviewServiceError.invalidURL
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LinkPreviewServiceError.networkError(
                NSError(domain: "HTTP", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            )
        }
        
        let apiResponse = try JSONDecoder().decode(APIResponse<LinkPreview>.self, from: data)
        
        guard let preview = apiResponse.data else {
            throw LinkPreviewServiceError.noMetadataFound
        }
        
        return preview
    }
    
    private func scrapeOpenGraph(url: URL) async throws -> LinkPreview {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LinkPreviewServiceError.networkError(
                NSError(domain: "HTTP", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            )
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw LinkPreviewServiceError.parsingError
        }
        
        return parseOpenGraph(from: html, url: url.absoluteString)
    }
    
    private func parseOpenGraph(from html: String, url: String) -> LinkPreview {
        let title = extractMetaProperty(html: html, property: "og:title") ??
                    extractTitle(from: html) ?? ""
        
        let description = extractMetaProperty(html: html, property: "og:description") ??
                          extractMetaName(html: html, name: "description") ?? ""
        
        let image = extractMetaProperty(html: html, property: "og:image")
        let siteName = extractMetaProperty(html: html, property: "og:site_name")
        
        return LinkPreview(
            url: url,
            title: title,
            description: description,
            image: image,
            siteName: siteName,
            favicon: extractFavicon(from: html, baseURL: url),
            type: extractMetaProperty(html: html, property: "og:type"),
            locale: extractMetaProperty(html: html, property: "og:locale")
        )
    }
    
    private func extractMetaProperty(html: String, property: String) -> String? {
        let pattern = "<meta[^>]*property=\\"\(property)\\"[^>]*content=\\"([^\\"]*)\\""
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else {
            return nil
        }
        return String(html[range])
    }
    
    private func extractMetaName(html: String, name: String) -> String? {
        let pattern = "<meta[^>]*name=\\"\(name)\\"[^>]*content=\\"([^\\"]*)\\""
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else {
            return nil
        }
        return String(html[range])
    }
    
    private func extractTitle(from html: String) -> String? {
        let pattern = "<title>([^<]*)</title>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else {
            return nil
        }
        return String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func extractFavicon(from html: String, baseURL: String) -> String? {
        if let base = URL(string: baseURL),
           let host = base.host {
            return "https://\(host)/favicon.ico"
        }
        return nil
    }
    
    // MARK: - Cache Management
    private func getCachedPreview(for url: String) -> LinkPreview? {
        guard let cached = cachedPreviews[url],
              Date().timeIntervalSince(cached.timestamp) < cacheTimeout else {
            return nil
        }
        return cached.preview
    }
    
    private func cachePreview(_ preview: LinkPreview, for url: String) {
        cachedPreviews[url] = CachedPreview(preview: preview, timestamp: Date())
    }
}
