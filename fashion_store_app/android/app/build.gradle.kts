plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.fashion_store_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.fashion_store_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // firebase_auth (and related Firebase Android SDKs) require API 23+.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    buildTypes {
        debug {
            // Avoid stripDebugDebugSymbols choking on non-regular files (OneDrive / Windows reparse points).
            ndk {
                debugSymbolLevel = "NONE"
            }
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

flutter {
    source = "../.."
}

// Do not add manual com.google.firebase / androidx.credentials dependencies here.
// FlutterFire plugins (firebase_core, firebase_auth) ship compatible native SDK versions.
// Extra BoM lines often cause duplicate classes or native crashes on real devices.

// OneDrive may create non-regular files in Gradle zip-cache and break snapshotting.
// Disable only the affected Java resource merge tasks, while keeping native packaging intact.
afterEvaluate {
    tasks.matching {
        val n = it.name
        n.contains("mergeDebugJavaResource", ignoreCase = true) ||
            n.contains("mergeReleaseJavaResource", ignoreCase = true)
    }.configureEach {
        enabled = false
    }
}

