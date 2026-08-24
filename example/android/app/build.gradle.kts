import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.github.triplet.play")
    id("maven-publish")
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
    ndkVersion = "28.1.13356709" // required by maplibre_gl

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

publishing {
    publications {
        android.applicationVariants.all {
            this.outputs.forEach { output ->
                val publicationName = output.outputFile.name.replace(".apk", "")
                create<MavenPublication>(publicationName) {
                    val path =
                        "${project.layout.buildDirectory.get().asFile.absolutePath}/outputs/bundle/release/${publicationName}.aab"
                    artifact(File(path))
                    groupId = "ch.sbb.rokas.flutter"
                    artifactId = "ch.sbb.maps.flutter.example"
                    version = flutter.versionName
                }
            }
        }
    }
    repositories {
        maven {
            name = "temp"
            url = uri(rootProject.layout.buildDirectory.get().asFile)
        }
    }
}

flutter {
    source = "../.."
}

dependencies {}

afterEvaluate {
    tasks.named("bundleRelease") {
        finalizedBy("assembleRelease")
    }
    tasks.named("assembleRelease") {
        finalizedBy("publishApp-releasePublicationToTempRepository")
    }
}

