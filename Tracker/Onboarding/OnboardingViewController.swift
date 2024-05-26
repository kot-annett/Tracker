//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Anna on 17.05.2024.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    private lazy var pages: [UIViewController] = {
        return [blueViewController, redViewController]
    }()
    
    private lazy var blueViewController: UIViewController = {
        let vc = UIViewController()
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "onboardingBlue")
        imageView.center = view.center
        vc.view.addSubview(imageView)
        return vc
    }()
    
    private lazy var redViewController: UIViewController = {
        let vc = UIViewController()
        let imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "onboardingRed")
        imageView.center = view.center
        vc.view.addSubview(imageView)
        return vc
    }()
    
    private lazy var labelBlue: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.text = "Отслеживайте только то, что хотите"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var labelRed: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.text = "Даже если это не литры воды и йога"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        return pageControl
    }()
    
    private lazy var enterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Вот это технологии!", for: .normal)
        button.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        setupUI()
    }
    
    @objc private func enterButtonTapped() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = TabBarController()
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let currentIndex = pageControl.currentPage
        setViewControllers([pages[currentIndex]], direction: .forward, animated: true, completion: nil)
    }
    
    private func setupUI() {
//        [blueViewController, redViewController].forEach { addChild($0) }
//        [blueViewController.view, redViewController.view].forEach {
//            view.addSubview($0)
//        }
        
        [pageControl, enterButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        blueViewController.view.addSubview(labelBlue)
        labelBlue.translatesAutoresizingMaskIntoConstraints = false
        
        redViewController.view.addSubview(labelRed)
        labelRed.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelBlue.centerXAnchor.constraint(equalTo: blueViewController.view.centerXAnchor),
            labelBlue.bottomAnchor.constraint(equalTo: blueViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -320),
            labelBlue.leadingAnchor.constraint(equalTo: blueViewController.view.leadingAnchor, constant: 16),
            labelBlue.trailingAnchor.constraint(equalTo: blueViewController.view.trailingAnchor, constant: -16),
            
            labelRed.centerXAnchor.constraint(equalTo: redViewController.view.centerXAnchor),
            labelRed.bottomAnchor.constraint(equalTo: redViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -320),
            labelRed.leadingAnchor.constraint(equalTo: redViewController.view.leadingAnchor, constant: 16),
            labelRed.trailingAnchor.constraint(equalTo: redViewController.view.trailingAnchor, constant: -16),
            
        
            pageControl.bottomAnchor.constraint(equalTo: enterButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            enterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            enterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            enterButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
                return nil
            }
            let previousIndex = viewControllerIndex - 1

            guard previousIndex >= 0 else {
//                return pages.last
                return nil
            }

            return pages[previousIndex]
        }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
                return nil
            }
            let nextIndex = viewControllerIndex + 1

            guard nextIndex < pages.count else {
                return nil
//                return pages.first
            }

            return pages[nextIndex]
        }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            if let currentViewController = pageViewController.viewControllers?.first,
               let currentIndex = pages.firstIndex(of: currentViewController) {
                pageControl.currentPage = currentIndex
            }
        }
}

