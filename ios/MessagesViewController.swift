import UIKit
import Messages
import MessagesUI

// MARK: - MessagesViewController
class MessagesViewController: MSMessagesAppViewController {
    
    // MARK: - Properties
    @IBOutlet private var containerView: UIView?
    private var currentMessage: MSMessage?
    private var messages: [MSMessage] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupContainerView()
    }
    
    private func setupContainerView() {
        guard let containerView = containerView else { return }
        containerView.backgroundColor = .systemBackground
    }
    
    // MARK: - Data Management
    private func loadMessages() {
        // Load messages from the conversation
        // Implement based on your data model
    }
    
    private func refreshUI() {
        // Refresh the UI based on the current state
        // This is called when the extension becomes active or transitions presentation styles
    }
    
    // MARK: - Message Creation
    private func createInstantLinkMessage(url: String, title: String, description: String) -> MSMessage {
        let session = activeConversation?.selectedMessage?.session ?? MSSession()
        let message = MSMessage(session: session)
        
        let layout = MSMessageTemplateLayout()
        layout.image = generateLinkPreviewImage(title: title, url: url)
        layout.caption = title
        layout.subcaption = description
        layout.trailingCaption = "Instant Link"
        
        message.layout = layout
        message.url = URL(string: url) ?? URL(string: "about:blank")!
        
        return message
    }
    
    // MARK: - Image Generation
    private func generateLinkPreviewImage(title: String, url: String) -> UIImage {
        let size = CGSize(width: 300, height: 200)
        UIGraphicsBeginImageContext(size)
        
        // Background gradient
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        gradient.draw(in: UIGraphicsGetCurrentContext()!)
        
        // Title text
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.white
        ]
        
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (size.width - titleSize.width) / 2,
            y: 20,
            width: titleSize.width,
            height: titleSize.height
        )
        title.draw(in: titleRect, withAttributes: titleAttributes)
        
        // URL text
        let urlFont = UIFont.systemFont(ofSize: 14)
        let urlAttributes: [NSAttributedString.Key: Any] = [
            .font: urlFont,
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        
        let urlSize = url.size(withAttributes: urlAttributes)
        let urlRect = CGRect(
            x: (size.width - urlSize.width) / 2,
            y: size.height - 40,
            width: urlSize.width,
            height: urlSize.height
        )
        url.draw(in: urlRect, withAttributes: urlAttributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func generateProfileImage(userName: String) -> UIImage {
        let size = CGSize(width: 300, height: 200)
        UIGraphicsBeginImageContext(size)
        
        // Background
        UIColor.systemBlue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Text
        let text = userName
        let font = UIFont.boldSystemFont(ofSize: 32)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - MSMessagesAppViewController
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        // Called when the extension is about to become active
    }
    
    override func didBecomeActive(with conversation: MSConversation) {
        super.didBecomeActive(with: conversation)
        // Called when the extension has become active
        refreshUI()
    }
    
    override func willResignActive(with conversation: MSConversation) {
        super.willResignActive(with: conversation)
        // Called when the extension is about to resign active
    }
    
    override func didResignActive(with conversation: MSConversation) {
        super.didResignActive(with: conversation)
        // Called when the extension has resigned active
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        // Called before the extension transitions presentation styles
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        // Called after the extension transitions presentation styles
        refreshUI()
    }
    
    // MARK: - Actions
    @objc private func handleSendTapped() {
        guard let conversation = activeConversation else { return }
        
        let message = createInstantLinkMessage(
            url: "https://example.com",
            title: "Check this out!",
            description: "Tap to view"
        )
        
        conversation.insert(message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MessagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Implement cell configuration based on your data model
        let cell = UICollectionViewCell()
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MessagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle item selection
    }
}
