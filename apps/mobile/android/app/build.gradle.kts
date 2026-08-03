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
            signingConfig = releaseConfig
            // 签名校验只在真正构建 release 变体时执行（debug 构建如
            // `flutter build apk --debug` 不应被 release 签名要求阻塞）。
            // CI 的 flutter-build-android 走 debug；发布包在 release-android
            // 阶段由 SCOLVPET_UPLOAD_* 环境变量提供签名。
            val buildingRelease = gradle.startParameter.taskNames.any {
                it.contains("Release") || it.contains("release")
            }
            if (buildingRelease) {
                check(releaseConfig?.storeFile != null) {
                    "Release signing is required. Set SCOLVPET_UPLOAD_* env vars or local properties."
                }
            }
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
