plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.olx_prototype"
    compileSdk = 36
    
    ndkVersion = "27.0.12077973"

    compileOptions {
        // ✅ Java 11 rakho (Flutter 3.22+ me supported hai)
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // ✅ Desugaring enable
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.olx_prototype"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))

    // Firebase SDKs
    implementation("com.google.firebase:firebase-analytics")

    // ✅ Java 8+ features ke liye ye add karna zaroori hai
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    // 💳 Razorpay dependencies (required for razorpay_flutter)
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.activity:activity:1.8.2")
    implementation("androidx.fragment:fragment:1.6.2")
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Additional dependencies for Android basic classes
    implementation("androidx.core:core:1.12.0")
    implementation("org.json:json:20231013")
    
    // SMS Retriever API for OTP autofill
    implementation("com.google.android.gms:play-services-auth:21.0.0")
    implementation("com.google.android.gms:play-services-auth-api-phone:18.0.2")
}
