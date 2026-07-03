plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.github.triplet.play")
    id("maven-publish")
}

val localProperties = java.util.Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { input ->
        localProperties.load(input)
    }
}

var flutterVersionCode: String? = localProperties.getProperty("flutter.versionCode")
if (flutterVersionCode == null) {
    flutterVersionCode = "1"
}

var flutterVersionName: String? = localProperties.getProperty("flutter.versionName")
if (flutterVersionName == null) {
    flutterVersionName = "1.0"
}

// for local signing
val keystoreProperties = java.util.Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { input ->
        keystoreProperties.load(input)
    }
}

android {
    namespace = "ch.sbb.maps.flutter"
    compileSdk = 36
    ndkVersion = "28.1.13356709" // required by geolocator_android & maplibre_gl

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDir("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "ch.sbb.maps.flutter.example"
        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode!!.toInt()
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(
                System.getenv("SIGNING_KEYSTORE_FILE")
                    ?: file("keys/sbb_maps_flutter_example_keystore.jks")
            )
            storePassword = System.getenv("SIGNING_KEYSTORE_PASSWORD")
                ?: keystoreProperties.getProperty("storePassword")
            keyAlias = System.getenv("SIGNING_KEY_ALIAS")
                ?: keystoreProperties.getProperty("keyAlias")
            keyPassword = System.getenv("SIGNING_KEY_PASSWORD")
                ?: keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        getByName("debug")
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    publishing {
        singleVariant("release") {
            withSourcesJar()
            withJavadocJar()
        }
    }
}

configure<com.github.triplet.gradle.androidpublisher.AndroidPublisherExtension> {
    serviceAccountCredentials.set(file("keys/google_playstore_service_account.json"))
    track.set("alpha")
    defaultToAppBundles.set(true)
    artifactDir.set(file("../../build/app/outputs/bundle/release"))
}

publishing {
    publications {
        android.applicationVariants.all {
            val flavorName = this.flavorName
            this.outputs.forEach { output ->
                val publicationName = output.outputFile.name.replace(".apk", "")
                create<MavenPublication>(publicationName) {
                    val path = "${project.buildDir.absolutePath}/outputs/bundle/release/${publicationName}.aab"
                    artifact(File(path))
                    groupId = "ch.sbb.rokas.flutter"
                    artifactId = "ch.sbb.maps.flutter.example"
                    version = flutterVersionName!!
                }
            }
        }
    }
    repositories {
        maven {
            name = "temp"
            url = uri("${rootProject.buildDir}")
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

