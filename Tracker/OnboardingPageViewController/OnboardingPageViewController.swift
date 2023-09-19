//
//  OnboardingPageViewController.swift
//  Tracker
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    private let blueImage = UIImage(named: "OnboardingBlue")
    private let redImage = UIImage(named: "OnboardingRed")
    private let userDefaults = UserDefaults.standard
    private let blueScreen = NSLocalizedString("BlueScreen", comment: "")
    private let redScreen = NSLocalizedString("RedScreen", comment: "")
    
    private lazy var blueImageView: UIImageView = {
        let view = UIImageView(image: blueImage)
        view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        return view
    }()
    
    private lazy var redImageView: UIImageView = {
        let view = UIImageView(image: redImage)
        view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        return view
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        let pageController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageController.dataSource = self
        pageController.delegate = self
        return pageController
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        
        return pageControl
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("OnboardingButton", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.backgroundColor = .blackDay
        button.addTarget(self, action: #selector(goToTrackerList), for: .touchUpInside)
        return button
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .blackDay
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = blueScreen
        return label
    }()
    
    private lazy var pages: [UIViewController] = {
        let blue = UIViewController()
        blue.view.addSubview(blueImageView)
        let red = UIViewController()
        red.view.addSubview(redImageView)
        return [blue, red]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = pages.first {
            pageViewController.setViewControllers([first], direction: .forward, animated: true)
        }
        
        setupUI()
    }
    
    @objc
    private func goToTrackerList() {
        let tabBarViewController = TabBarViewController()
        tabBarViewController.modalPresentationStyle = .fullScreen
        show(tabBarViewController, sender: nil)
        completeOnboarding()
    }
    
    private func setupUI() {
        [pageViewController.view, pageControl, nextButton, textLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        addChild(pageViewController)
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            nextButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: "isFirstLaunch")
    }
}
// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        if previousIndex < 0 {
            textLabel.text = blueScreen
            return pages.last
        } else {
            textLabel.text = redScreen
            return pages[previousIndex]
        }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        if nextIndex >= pages.count {
            textLabel.text = redScreen
            return pages.first
        } else {
            textLabel.text = blueScreen
            return pages[nextIndex]
        }
    }
}
// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
