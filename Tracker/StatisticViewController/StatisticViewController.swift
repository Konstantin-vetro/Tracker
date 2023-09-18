//
//  StatisticViewController.swift
//  Tracker
//

import UIKit

protocol StatisticViewControllerDelegate: AnyObject {
    func showCompletedTrackers(_ completeTrackers: Int)
}

final class StatisticViewController: UIViewController {
    private let analyticsService: AnalyticsServiceProtocol = AnalyticsService()
    private var completeTrackers: Int? {
        get {
            UserDefaults.standard.integer(forKey: "completeTrackers")
        } set {
            UserDefaults.standard.set(newValue, forKey: "completeTrackers")
            updateCompleteTrackersUI()
        }
    }
    
    private lazy var statisticView: UIView = {
        let view = UIView()
        view.backgroundColor = .BackgroundDay
        view.layer.cornerRadius = 16
        view.addSubview(countTrackers)
        view.addSubview(descriptionCount)
        return view
    }()
    
    private lazy var countTrackers: UILabel = {
        let label = UILabel()
        label.text = completeTrackers?.description
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .BlackDay
        return label
    }()
    
    private lazy var descriptionCount: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("TrackersCompleted", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .BlackDay
        label.textAlignment = .left
        return label
    }()
// MARK: - LyfeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.openScreenReport(screen: .statistics)
        showBackgroundView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.closeScreenReport(screen: .statistics)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let gradientLayer = createGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        applyGradientBorder(to: statisticView, gradientLayer: gradientLayer)
    }
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .BackgroundDay
        view.addSubview(statisticView)
        [statisticView, countTrackers, descriptionCount].forEach { $0.translatesAutoresizingMaskIntoConstraints = false}
        
        NSLayoutConstraint.activate([
            statisticView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            statisticView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticView.heightAnchor.constraint(equalToConstant: 90),
            
            countTrackers.topAnchor.constraint(equalTo: statisticView.topAnchor, constant: 12),
            countTrackers.leadingAnchor.constraint(equalTo: statisticView.leadingAnchor, constant: 12),
            
            descriptionCount.topAnchor.constraint(equalTo: countTrackers.bottomAnchor, constant: 7),
            descriptionCount.leadingAnchor.constraint(equalTo: statisticView.leadingAnchor, constant: 12)
        ])
    }
    
    private func updateCompleteTrackersUI() {
        countTrackers.text = completeTrackers?.description
    }
    
    private func showBackgroundView() {
        if completeTrackers == 0 {
            let emptyView = EmptyView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: view.bounds.width,
                                                    height: view.bounds.height),
                                      text: NSLocalizedString("NoAnalyze", comment: ""),
                                      uiImage: UIImage(named: "noStatisticsPlaceholder"))
            view = emptyView
        } else {
            view = UIView()
            setupUI()
            updateCompleteTrackersUI()
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("Statistics", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    // MARK: - Setup Gradient Border
    func createGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.gradientRed.cgColor,
            UIColor.gradientGreen.cgColor,
            UIColor.gradientBlue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradientLayer
    }
    
    private func applyGradientBorder(to view: UIView,
                                     gradientLayer: CAGradientLayer,
                                     cornerRadius: CGFloat = 16,
                                     borderWidth: CGFloat = 1.5) {
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: view.bounds, cornerRadius: cornerRadius)
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = borderWidth
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        gradientLayer.mask = shapeLayer
        view.layer.addSublayer(gradientLayer)
    }
}

extension StatisticViewController: StatisticViewControllerDelegate {
    func showCompletedTrackers(_ completeTrackers: Int) {
        self.completeTrackers = completeTrackers
    }
}
