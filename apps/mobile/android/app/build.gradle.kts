import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val mobileIdentifierProperties = Properties().apply {
    rootProject.file("mobile-identifiers.properties").inputStream().use { input -> load(input) }
}
val mobileAppId = mobileIdentifierProperties.getProperty("SCOLVPET_APP_ID")
    ?: error("SCOLVPET_APP_ID is missing from mobile-identifiers.properties")

android {
    namespace = mobileAppId
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        // Required by flutter_local_notifications (java.time APIs on older minSdk).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = mobileAppId
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
