import Flutter
import UIKit
import FirebaseCore
import FirebaseUI

public class SwiftFirebaseAuthUiPlugin: NSObject, FlutterPlugin, FUIAuthDelegate {
        private var result: FlutterResult?
        private var authUI: FUIAuth?

        /**
         * Indicates that user cancelled the sign-in process via back or cancel button
         */
        private let ERROR_USER_CANCELLED = "ERROR_USER_CANCELLED"
        /**
         * Indicates the firebase error. The error should have message and detail showing
         * the firebase error code which can be used to handle error more precisely.
         */
        private let ERROR_FIREBASE = "ERROR_FIREBASE"
        /**
         * Indicates an unknown error occurred during sign-in process
         */
        private let ERROR_UNKNOWN = "ERROR_UNKNOWN"
        /**
         * Indicates an error in initializing.
         */
        private let ERROR_INITIALIZATION = "ERROR_INITIALIZATION"

        override init() {
            super.init()
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
            authUI = FUIAuth.defaultAuthUI()!
            authUI?.delegate = self
        }

        public static func register(with registrar: FlutterPluginRegistrar) {
            let channel = FlutterMethodChannel(name: "firebase_auth_ui", binaryMessenger: registrar.messenger())

            let instance = SwiftFirebaseAuthUiPlugin()
            registrar.addMethodCallDelegate(instance, channel: channel)
        }

        public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
                if (call.method == "launchFlow") {
                    guard let args = call.arguments as? [String: Any] else {
                        result(FlutterError(code: ERROR_INITIALIZATION, message: "iOS could not recognize flutter arguments in method: (sendParams)",
                                            details: nil))
                        return
                    }
                    guard let providers = args["providers"] as? [String] else {
                        result(FlutterError(code: ERROR_INITIALIZATION, message: "Please pass providers.",
                                            details: nil))
                        return
                    }
                    
                    let tos = args["tos"] as? String ?? ""
                    let privacyPolicy = args["privacyPolicy"] as? String ?? ""

                    let authProviders = getAuthProviders(providers: providers)
                    authUI?.providers = authProviders

                    if (!tos.isEmpty && !privacyPolicy.isEmpty) {
                        authUI?.tosurl = URL(string: tos)!
                        authUI?.privacyPolicyURL = URL(string: privacyPolicy)!
                    }

                    let authViewController = authUI!.authViewController()
                    self.result = result
                    launchFlow(authViewController: authViewController)
                } else if (call.method == "logout") {
                    do {
                        try authUI?.signOut()
                        result(true)
                    } catch {
                        result(false)
                    }
                }
            }

        public func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
            if (error != nil) {
                if (UInt((error as NSError?)?.code ?? -12) == FUIAuthErrorCode.userCancelledSignIn.rawValue) {
                    result?(FlutterError(code: ERROR_USER_CANCELLED, message: "User cancelled the sign-in flow",
                                         details: nil))
                } else {
                    result?(FlutterError(code: ERROR_UNKNOWN, message: "Unknown error occurred.",
                                         details: nil))
                }
            } else {
                let userDisctionary : NSMutableDictionary = [
                    "display_name": user?.displayName ?? "",
                    "email": user?.email ?? "",
                    "provider_id": user?.providerID ?? "",
                    "uid": user?.uid ?? "",
                    "photo_url": user?.photoURL?.absoluteString ?? "",
                    "phone_number": user?.phoneNumber ?? "",
                    "is_anonymous": user?.isAnonymous ?? false,
                ]
                result?(userDisctionary)
            }
        }

        private func launchFlow(authViewController: UIViewController) {
            let viewController = UIApplication.shared.delegate!.window!!.rootViewController!
            viewController.present(authViewController, animated: true)
        }

        private func getAuthProviders(providers: Array<String>) -> Array<FUIAuthProvider> {
            var authProviders = Array<FUIAuthProvider>()
            if (!providers.isEmpty) {
                providers.forEach { provider in
                    if (provider == "password") {
                        authProviders.append(FUIEmailAuth())
                    } else if (provider == "google") {
                        authProviders.append(FUIGoogleAuth())
                    } else if (provider == "facebook") {
                        authProviders.append(FUIFacebookAuth())
                    }
                }
            }

            return authProviders
        }
}
