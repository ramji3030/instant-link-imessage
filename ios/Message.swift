import Foundation

// MARK: - Message Model
/// Represents a shareable link message in the Instant Link system
struct Message: Codable, Identifiable, Hashable {
    let id: String
    let url: String
    let title: String
    let description: String
    let imageURL: String?
    let siteName: String?
    let faviconURL: String?
    let createdAt: Date
    let createdBy: User
    var shareCount: Int
    var clickCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case title
        case description
        case imageURL = "image_url"
        case siteName = "site_name"
        case faviconURL = "favicon_url"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case shareCount = "share_count"
        case clickCount = "click_count"
    }
    
    init(
        id: String = UUID().uuidString,
        url: String,
        title: String,
        description: String,
        imageURL: String? = nil,
        siteName: String? = nil,
        faviconURL: String? = nil,
        createdAt: Date = Date(),
        createdBy: User,
        shareCount: Int = 0,
        clickCount: Int = 0
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.siteName = siteName
        self.faviconURL = faviconURL
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.shareCount = shareCount
        self.clickCount = clickCount
    }
    
    // MARK: - Computed Properties
    var displayTitle: String {
        return title.isEmpty ? url : title
    }
    
    var displayDescription: String {
        return description.isEmpty ? "Tap to view link" : description
    }
    
    var domainName: String? {
        guard let url = URL(string: url) else { return nil }
        return url.host
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - User Model
/// Represents a user in the Instant Link system
struct User: Codable, Identifiable, Hashable {
    let id: String
    let username: String
    let displayName: String?
    let avatarURL: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case email
    }
    
    init(
        id: String = UUID().uuidString,
        username: String,
        displayName: String? = nil,
        avatarURL: String? = nil,
        email: String? = nil
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.email = email
    }
    
    var displayUsername: String {
        return displayName ?? username
    }
}

// MARK: - Link Preview Model
/// Represents OpenGraph metadata for link previews
struct LinkPreview: Codable, Identifiable {
    let id: String
    let url: String
    let title: String
    let description: String
    let image: String?
    let siteName: String?
    let favicon: String?
    let type: String?
    let locale: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
        case title
        case description
        case image
        case siteName = "site_name"
        case favicon
        case type
        case locale
    }
    
    init(
        id: String = UUID().uuidString,
        url: String,
        title: String,
        description: String,
        image: String? = nil,
        siteName: String? = nil,
        favicon: String? = nil,
        type: String? = nil,
        locale: String? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.description = description
        self.image = image
        self.siteName = siteName
        self.favicon = favicon
        self.type = type
        self.locale = locale
    }
    
    // MARK: - Conversion to Message
    func toMessage(createdBy: User) -> Message {
        return Message(
            url: url,
            title: title,
            description: description,
            imageURL: image,
            siteName: siteName,
            faviconURL: favicon,
            createdBy: createdBy
        )
    }
}

// MARK: - API Response Wrappers
/// Generic API response wrapper for paginated results
struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let page: Int
    let perPage: Int
    let total: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case data
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
    }
}

/// Generic API response wrapper for single resources
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let errors: [APIError]?
}

/// API error model
struct APIError: Codable {
    let code: String
    let message: String
    let field: String?
}

// MARK: - Message Metadata
/// Additional metadata for messages
struct MessageMetadata: Codable {
    let isFavorite: Bool
    let isArchived: Bool
    let tags: [String]
    let customTitle: String?
    let customDescription: String?
    
    init(
        isFavorite: Bool = false,
        isArchived: Bool = false,
        tags: [String] = [],
        customTitle: String? = nil,
        customDescription: String? = nil
    ) {
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.tags = tags
        self.customTitle = customTitle
        self.customDescription = customDescription
    }
}
