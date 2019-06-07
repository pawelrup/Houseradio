//
//  AppDelegate.swift
//  Houseradio
//
//  Created by Pawel Rup on 15/10/2018.
//  Copyright © 2018 Pawel Rup. All rights reserved.
//

import UIKit
import UserNotifications
import AVKit
import RxSwift
import RxUserNotifications
import RxRadioPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	static var shared: AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}

	var window: UIWindow?
	private let audioSession = AVAudioSession.sharedInstance()
	private var appCoordinator: AppCoordinator!
	lazy var radioPlayer = RadioPlayer(audioSession: self.audioSession)
	lazy var quickActionsManager = QuickActionsManager(radioPlayer: self.radioPlayer)
	let routeDetector = AVRouteDetector()
	let disposeBag = DisposeBag()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow()

		do {
			try audioSession.setCategory(.playback, mode: .default, policy: .longForm)
			try audioSession.setActive(true)
		} catch {
			fatalError(error.localizedDescription)
		}
		StoreKitManager.incrementNumberOfTimesLaunched()
		appCoordinator = AppCoordinator(window: window!)
		appCoordinator.start()
			.subscribe()
			.disposed(by: disposeBag)
		UNUserNotificationCenter.current().rx
			.requestAuthorization(options: [.alert, .badge, .sound])
			.observeOn(MainScheduler.instance)
			.subscribe(onSuccess: { _ in
				UIApplication.shared.registerForRemoteNotifications()
			})
			.disposed(by: disposeBag)
		return true
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		quickActionsManager.setPlayShortcut()
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let token = Observable.just(deviceToken)
			.map { $0.map { String(format: "%02x", $0) }.joined() }
		let language = Observable.just("LANGUAGE_CODE".localized)
			.flatMapLatest(LanguagesManager.getLanguage)
			.map { $0.id }
		let model = Observable.just(UIDevice.current.modelName)
		let systemVersion = Observable.just(UIDevice.current.systemVersion)
		let bundleShortVersion = Observable.just(Bundle.main.bundleShortVersion ?? "")
		Observable.combineLatest(token, language, model, systemVersion, bundleShortVersion)
			.map { PushTokenData(token: $0, languageID: $1, deviceModelIdentifier: $2, systemVersion: $3, appVersion: $4) }
			.flatMapLatest { PushTokensManager.send(tokenData: $0) }
			.subscribe()
			.disposed(by: disposeBag)
	}
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		quickActionsManager.performAction(for: shortcutItem, completionHandler: completionHandler)
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		routeDetector.isRouteDetectionEnabled = true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		routeDetector.isRouteDetectionEnabled = false
	}
}
