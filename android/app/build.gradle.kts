plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.outvisionxr"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.outvisionxr"

        // ✅ ARCore (Geospatial) requer minSdk 24
        minSdk = 24

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))
    // Firebase Analytics (mínimo recomendado)
    implementation("com.google.firebase:firebase-analytics")
    // AR + 3D (Filament + ARCore)
    implementation("io.github.sceneview:arsceneview:2.3.1")
    // Lifecycle para PlatformView
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
}

flutter {
    source = "../.."
}