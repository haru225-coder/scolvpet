import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val mobileIdentifierProperties = Properties().apply {
    rootProject.file("mobile-identifiers.properties").inputStream().use { input -> load(input) }
}
// Customer-facing store ID (may change for production).
val mobileAppId = mobileIdentifierProperties.getProperty("SCOLVPET_APP_ID")
    ?: error("SCOLVPET_APP_ID is missing from mobile-identifiers.properties")
// Kotlin source package / R class namespace — do NOT couple to applicationId.
val mobileNamespace = mobileIdentifierProperties.getProperty("SCOLVPET_NAMESPACE")
    ?: "cn.scolvpet.dev"

android {
    namespace = mobileNamespace
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

    signingConfigs {
        create("release") {
            val storeFilePath = System.getenv("SCOLVPET_UPLOAD_STORE_FILE")
                ?: mobileIdentifierProperties.getProperty("SCOLVPET_UPLOAD_STORE_FILE")
            val storePassword = System.getenv("SCOLVPET_UPLOAD_STORE_PASSWORD")
                ?: mobileIdentifierProperties.getProperty("SCOLVPET_UPLOAD_STORE_PASSWORD")
            val keyAlias = System.getenv("SCOLVPET_UPLOAD_KEY_ALIAS")
                ?: mobileIdentifierProperties.getProperty("SCOLVPET_UPLOAD_KEY_ALIAS")
            val keyPassword = System.getenv("SCOLVPET_UPLOAD_KEY_PASSWORD")
                ?: mobileIdentifierProperties.getProperty("SCOLVPET_UPLOAD_KEY_PASSWORD")
            if (!storeFilePath.isNullOrBlank() &&
                !storePassword.isNullOrBlank() &&
                !keyAlias.isNullOrBlank() &&
                !keyPassword.isNullOrBlank()
            ) {
                storeFile = file(storeFilePath)
                this.storePassword = storePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            }
        }
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.findByName("release")
            val hasReleaseKeystore = releaseConfig?.storeFile != null
            check(hasReleaseKeystore) {
                "Release signing is required. Set SCOLVPET_UPLOAD_* env vars or local properties."
            }
            signingConfig = releaseConfig
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
