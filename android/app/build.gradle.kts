import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader().use { reader ->
        localProperties.load(reader)
    }
}

val flutterRoot: String = localProperties.getProperty("flutter.sdk")
    ?: throw GradleException("Flutter SDK not found. Define 'flutter.sdk' in local.properties.")

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toInt() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.mechat.app"
    // Best Practice: Target the latest STABLE SDK version (Android 14)
    compileSdk = 35

    defaultConfig {
        applicationId = "com.mechat.app"
        minSdk = 23
        // Best Practice: Target the latest STABLE SDK version
        targetSdk = 35
        versionCode = flutterVersionCode
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    // --- CRITICAL FIX IS HERE ---
    // This block now correctly handles signing.
    // The build will FAIL if your key.properties file is missing or has a typo,
    // which prevents unsigned release APKs from being built.
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            // This line tells Gradle to use the signing configuration defined above.
            signingConfig = signingConfigs.findByName("release")
            
            // Note: For release builds, you might consider enabling these later for optimization.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    buildFeatures {
        viewBinding = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.9.0")
    implementation("androidx.core:core:1.9.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    implementation(platform("com.google.firebase:firebase-bom:32.0.0"))
    implementation("com.google.firebase:firebase-messaging")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}