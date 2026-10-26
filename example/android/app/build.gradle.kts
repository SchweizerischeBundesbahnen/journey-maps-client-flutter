import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.github.triplet.play")
}

// for local signing
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "ch.sbb.maps.flutter"
    compileSdk = flutter.compileSdkVersion
    // preinstalled on the GitHub ubuntu runner; must not be lower than the plugins' NDK (28.2)
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    defaultConfig {
        applicationId = "ch.sbb.maps.flutter.example"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(
                System.getenv("SIGNING_KEYSTORE_FILE")
                    ?: file("keys/sbb_maps_flutter_example_keystore.jks")
            )
            storePassword = System.getenv("SIGNING_KEYSTORE_PASSWORD")
                ?: keystoreProperties.getProperty("storePassword")
            keyAlias =
                System.getenv("SIGNING_KEY_ALIAS") ?: keystoreProperties.getProperty("keyAlias")
            keyPassword = System.getenv("SIGNING_KEY_PASSWORD")
                ?: keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_21
    }
}

play {
    serviceAccountCredentials.set(file("keys/google_playstore_service_account.json"))
    track.set("alpha")
    defaultToAppBundles.set(true)
    artifactDir.set(file("../../build/app/outputs/bundle/release"))
}

flutter {
    source = "../.."
}

dependencies {}

