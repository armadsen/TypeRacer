//
//  MenuViewController.swift
//  Typist
//
//  Created by Simon Elhoej Steinmejer on 25/09/18.
//  Copyright © 2018 Simon Elhoej Steinmejer. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var sourceButton: UIButton?
    let wpmResultController = WpmResultController()
    var averageWpm: Int?
    var wpmDoubles = [Double]()
    var wobbleTimer: Timer?

    let waveAnimationView: WaveAnimationView = {
        let wav = WaveAnimationView()

        return wav
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "orange juice", size: 60)
        label.sizeToFit()
        label.textColor = .white
        label.text = "TypeRacer"

        return label
    }()

    private func createMenuButton(title: String, fontSize: CGFloat = 36, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.enableDropShadow()
        button.titleLabel?.font = Appearance.titleFont(with: fontSize)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }

    lazy var playButton: UIButton = self.createMenuButton(title: "Play", action: #selector(handlePlay))
    lazy var practiceButton: UIButton = self.createMenuButton(title: "Practice", fontSize: 32, action: #selector(handlePractice))
    lazy var statsButton: UIButton = self.createMenuButton(title: "Stats", action: #selector(handleStats))
    lazy var leaderboardButton: UIButton = self.createMenuButton(title: "Leaderboard", fontSize: 18, action: #selector(handleLeaderboard))

    override func viewDidLayoutSubviews() {
        playButton.setGradientButton(colorOne: UIColor.lightBlue.cgColor, colorTwo: UIColor.lightPurple.cgColor, startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        practiceButton.setGradientButton(colorOne: UIColor.lightBlue.cgColor, colorTwo: UIColor.lightPurple.cgColor, startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1))
        statsButton.setGradientButton(colorOne: UIColor.lightBlue.cgColor, colorTwo: UIColor.lightPurple.cgColor, startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 0))
        leaderboardButton.setGradientButton(colorOne: UIColor.lightBlue.cgColor, colorTwo: UIColor.lightPurple.cgColor, startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0))
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        waveAnimationView.startAnimation()
        startWobbleTimer()
        wpmResultController.fetchWpmResults {
            self.calculateAverageWpm()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        waveAnimationView.stopAnimation()
        wobbleTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.setGradientBackground(colorOne: UIColor.darkBlue.cgColor, colorTwo: UIColor.rgb(red: 0, green: 23, blue: 40).cgColor)

        setupViews()
    }

    private func startWobbleTimer() {
        wobbleTimer = Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(handleWobbleAnimation), userInfo: nil, repeats: true)
    }

    @objc private func handleWobbleAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {

            self.playButton.titleLabel?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)

        }, completion: { _ in

            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {

                self.playButton.titleLabel?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)

            }, completion: { (_) in

                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {

                    self.playButton.titleLabel?.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.3)

                }, completion: { (_) in

                    UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {

                        self.playButton.titleLabel?.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)

                    }, completion: nil)
                })
            })
        })
    }

    private func calculateAverageWpm() {
        if wpmResultController.wpmResults.isEmpty {
            return
        }
        wpmDoubles.removeAll()
        var sum = 0
        for result in wpmResultController.wpmResults {
            let wpm = Int(result.wpm)
            self.wpmDoubles.append(Double(wpm))
            sum += wpm
        }
        let average = sum / wpmResultController.wpmResults.count
        self.averageWpm = average

        let attributedText = NSMutableAttributedString(string: "\(average)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: Appearance.titleFont(with: 46)])
        attributedText.append(NSAttributedString(string: "\nwpm", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: Appearance.titleFont(with: 18)]))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.string.count))

        statsButton.setAttributedTitle(attributedText, for: .normal)
    }

    @objc private func handlePlay() {
        sourceButton = playButton
        let typeController = TypeController()
        typeController.wpmResultController = self.wpmResultController
        typeController.transitioningDelegate = self
        present(typeController, animated: true, completion: nil)
    }

    @objc private func handlePractice() {
        sourceButton = practiceButton
        let typeController = TypeController()
        typeController.wpmResultController = self.wpmResultController
        typeController.transitioningDelegate = self
        present(typeController, animated: true, completion: nil)
    }

    @objc private func handleStats() {
        guard let averageWpm = averageWpm else { return }
        let statsViewController = StatsViewController()
        statsViewController.averageWpm = averageWpm
        print(wpmDoubles)
        statsViewController.wpmDoubles = wpmDoubles
        statsViewController.modalPresentationStyle = .overCurrentContext
        //        statsViewController.transitioningDelegate = self
        present(statsViewController, animated: true, completion: nil)
    }

    @objc private func handleLeaderboard() {
        let leaderboardViewController = LeaderboardViewController()
        leaderboardViewController.modalPresentationStyle = .overCurrentContext
        present(leaderboardViewController, animated: true, completion: nil)
    }

    private func setupViews() {
        view.addSubview(waveAnimationView)
        waveAnimationView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: 0, height: 0)

        let firstRow = UIStackView(arrangedSubviews: [playButton, practiceButton])
        firstRow.axis = .horizontal
        firstRow.spacing = 12
        firstRow.distribution = .fillEqually

        let secondRow = UIStackView(arrangedSubviews: [statsButton, leaderboardButton])
        secondRow.axis = .horizontal
        secondRow.spacing = 12
        secondRow.distribution = .fillEqually

        let verticalStackView = UIStackView(arrangedSubviews: [firstRow, secondRow])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 12
        verticalStackView.distribution = .fillEqually

        view.addSubview(verticalStackView)
        verticalStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 150, paddingLeft: 12, paddingRight: 12, paddingBottom: 0, width: 0, height: 300)

        view.addSubview(titleLabel)
        titleLabel.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: verticalStackView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 14, paddingRight: 0, paddingBottom: -12, width: 0, height: 0)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is TypeController {
            guard let sourceButton = sourceButton else { return nil }
            return PlayTransitonAnimator(sourceButton: sourceButton)
        } else {
            return PopoverTransitionAnimator()
        }
    }
}
