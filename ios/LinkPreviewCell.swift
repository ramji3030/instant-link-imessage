import UIKit

class LinkPreviewCell: UITableViewCell {
    static let reuseIdentifier = "LinkPreviewCell"
    
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

      override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(previewImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            previewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            previewImageView.widthAnchor.constraint(equalToConstant: 80),
            previewImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with linkPreview: LinkPreview) {
        titleLabel.text = linkPreview.title
        descriptionLabel.text = linkPreview.description
    }
}
