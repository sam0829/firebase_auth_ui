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
                    } else if (provider == "twitter") {
                        authProviders.append(getTwitterAuthProvider())
                    } else if (provider == "phone") {
                        authProviders.append(FUIPhoneAuth(authUI: authUI!))
                    }
                }
            }

            return authProviders
        }

        private func getTwitterAuthProvider() -> FUIOAuth {
            let twitterBase64 = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAAsTAAALEwEAmpwYAAABWWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgpMwidZAAAC00lEQVRIDZ2WMWgVQRCG371LVNBCUIySaIxt0FIwFlopogSRFGI6sUpnpSCoYCPYiI0a0EbQTrDUwkYRJFhoZTBCQAsTRLRJJLmX8/t3d9a9d5cYHPhuZmdnZ2f3du+9rPUfUpZlxrA2lFmWrdCWLTq0S3Qr+JztGsGhvjVFycVqQfT1Qm79LjiZNcfuWGe3ZmBbFcuPfRw1BrvhB7yARzaefvl9LhoXYBiHBm6Q7hb8sWrsu9Akz3GegEmQvVkJc5iBT9CnxOgeiMsMPtfGfwXKFQS1BMtBd9AmvzDOwrCS9cEXkMzCMaseW5Nrsp4wyQD2PEiUOBVNWASHCn4HZzTBFpAjlds0hmwi0/hOhiAlExUJq5JvAc7bOE3yUF5k0Sv3/MnzAYzCXgWjT4GkcQL8tqpbId5vMx39MA0SBVmgc/CYg9fwBqxy07ii2LgbNoH2V8dpAl7CPtB+64LoOApVsSOAcitpcRzjqXJO/zDfd/Mp2Tc4B3vgN7gXirbbmU6mBLorqJooTmMk017hIHiZhtsztO6ALkeaQbYGamK/pxgNotUqdh7eV/rZpjY8iTv5d58T1z9N2/+nSk60/6RguGWhN8Jl+AySppfoe+pPxbqLVhTF6TCB22rbM/n64ShoNf4rSGOdUhCnXK/yPH8WxsTvUPw6kve+kgdJr775mnQad1jJCbKD4ufCEV8q9k3LktxMc3VrJbe9vx6SVw8CAVqB7kOvn85VsIv2NdCVlzS9DyW26u8lY2Ox5qtoBm2DcZgCSZpctj5oVrX671gC7PSdOreqH8E6AlthCA7CIEh0RyRWVbq3X/Ff4h49VoCSY+suVIWO7XARPsB65CNBV2GnMqFVZK1ym8Uqc20CD2Acgv2gY7sJlmAOZuAtTFHpAtpOS/yhl68moYJ06bWYbgdjdChWrTqNjyvQRHTYIF00/SXB7fzqs1j3VyVNspb9B6yjGjCZd0v7AAAAAElFTkSuQmCC"

            let dataDecoded : Data = Data(base64Encoded: twitterBase64, options: .ignoreUnknownCharacters)!
            let twitterIcon = UIImage(data: dataDecoded)
            let buttonColor =
                UIColor(red: 71.0/255.0, green: 154.0/255.0, blue: 234.0/255.0, alpha: 1.0)

            return FUIOAuth(authUI: authUI!,
                                    providerID: "twitter.com",
                                    buttonLabelText: "Login with Twitter",
                                    shortName: "Twitter",
                                    buttonColor: buttonColor,
                                    iconImage: twitterIcon ?? UIImage(),
                                    scopes: ["user.read"],
                                    customParameters: ["prompt" : "consent"],
                                    loginHintKey: nil)
        }

        public func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
                let path = Bundle.main.path(forResource: "firebase_auth_ui", ofType: "bundle")
                let bundle = Bundle(path: path!)

                return CustomFUIAuthPickerViewController(nibName: "CustomFUIAuthPickerViewController",
                                                          bundle: bundle,
                                                          authUI: authUI)
        }
}
