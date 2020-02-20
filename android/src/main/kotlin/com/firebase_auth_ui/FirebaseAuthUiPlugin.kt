package com.firebase_auth_ui

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.firebase.ui.auth.AuthUI
import com.firebase.ui.auth.IdpResponse
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.firebase.auth.FirebaseAuth
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar


class FirebaseAuthUiPlugin(private val activity: Activity) : MethodCallHandler, PluginRegistry.ActivityResultListener {

    private var result: Result? = null

    companion object {
        /**
         * Indicates that user cancelled the sign-in process via back or cancel button
         */
        private const val ERROR_USER_CANCELLED = "ERROR_USER_CANCELLED"
        /**
         * Indicates the firebase error. The error should have message and detail showing
         * the firebase error code which can be used to handle error more precisely.
         */
        private const val ERROR_FIREBASE = "ERROR_FIREBASE"
        /**
         * Indicates an unknown error occurred during sign-in process
         */
        private const val ERROR_UNKNOWN = "ERROR_UNKNOWN"
        /**
         * Indicates an error in initializing.
         */
        private const val ERROR_INITIALIZATION = "ERROR_INITIALIZATION"

        private const val AUTH_REQUEST_CODE = 2000

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "firebase_auth_ui")
            val plugin = FirebaseAuthUiPlugin(registrar.activity())
            registrar.addActivityResultListener(plugin)
            channel.setMethodCallHandler(plugin)
        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == AUTH_REQUEST_CODE) {
            val response = IdpResponse.fromResultIntent(data)
            Log.e("AuthPlugin", "requestCode $requestCode, resultCode $resultCode, response $response")
            if (resultCode == Activity.RESULT_OK) {
                val user = FirebaseAuth.getInstance().currentUser

                if (user != null) {
                    val userMap = hashMapOf<String, Any>()
                    userMap["display_name"] = user.displayName ?: ""
                    userMap["uid"] = user.uid
                    userMap["email"] = user.email ?: ""
                    userMap["phone_number"] = user.phoneNumber ?: ""
                    userMap["provider_id"] = user.providerId
                    userMap["photo_url"] = user.photoUrl?.toString() ?: ""
                    userMap["is_anonymous"] = user.isAnonymous

                    result?.success(userMap)
                } else {
                    result?.error(ERROR_UNKNOWN, "Unknown error occurred.", null)
                }
            } else if (response == null) {
                result?.error(ERROR_USER_CANCELLED, "User cancelled the sign-in flow", null)
            } else {
                result?.error(ERROR_FIREBASE, response.error?.message, response.error?.errorCode?.toString())
            }
        }
        return false
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "launchFlow" -> {
                val authProviders = call.argument<List<String>>("providers")

                if (authProviders?.isEmpty() == true) {
                    result.error(ERROR_INITIALIZATION, "Please pass providers.", null)
                    return
                }
                val tos = call.argument<String>("tos")
                val privacyPolicy = call.argument<String>("privacyPolicy")

                this.result = result
                openAuthUI(getProviders(authProviders), tos, privacyPolicy)
            }
            "logout" -> AuthUI.getInstance()
                    .signOut(activity)
                    .addOnCompleteListener {
                        result.success(it.isSuccessful)
                    }
                    .addOnFailureListener {
                        result.success(false)
                    }
            else -> result.notImplemented()
        }
    }

    private fun getProviders(authProviders: List<String>?): List<AuthUI.IdpConfig> {
        val providers = mutableListOf<AuthUI.IdpConfig>()
        authProviders?.forEach {
            when (it) {
                "password" -> providers.add(AuthUI.IdpConfig.EmailBuilder().build())
                "google" -> providers.add(AuthUI.IdpConfig.GoogleBuilder()
                        .build())
                "facebook" -> providers.add(AuthUI.IdpConfig.FacebookBuilder()
                        .build())
                "twitter" -> providers.add(AuthUI.IdpConfig.TwitterBuilder()
                        .build())
                "phone" -> providers.add(AuthUI.IdpConfig.PhoneBuilder()
                        .build())
            }
        }
        return providers
    }

    private fun openAuthUI(providers: List<AuthUI.IdpConfig>, tos: String?, privacyPolicy: String?) {
        var instance = AuthUI.getInstance()
                .createSignInIntentBuilder()
                .setAvailableProviders(providers)

        val logoResourceId = getLogoResourceId()
        if (logoResourceId > 0)
            instance = instance.setLogo(logoResourceId)

        if (tos?.isNotEmpty() == true && privacyPolicy?.isNotEmpty() == true)
            instance = instance.setTosAndPrivacyPolicyUrls(tos, privacyPolicy)

        activity.startActivityForResult(instance.build(),
                AUTH_REQUEST_CODE)
    }

    private fun getLogoResourceId(): Int {
        return activity.resources.getIdentifier("auth_ui_logo", "drawable", activity.packageName)
    }
}
