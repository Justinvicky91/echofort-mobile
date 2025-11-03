import java.util.Properties
import java.io.FileInputStream
import java.io.File
import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Decode and load keystore for release signing
val keystoreProperties = Properties()
val keystoreDir = File(projectDir, "keystore")
val base64KeystoreFile = File(keystoreDir, "release.keystore.base64")
val signingPropsFile = File(keystoreDir, "signing.properties")
val decodedKeystoreFile = File(keystoreDir, "release.keystore")

if (base64KeystoreFile.exists() && signingPropsFile.exists()) {
    println("🔐 Decoding keystore from base64...")
    
    // Decode base64 keystore
    val base64Content = base64KeystoreFile.readText().trim()
    val keystoreBytes = Base64.getDecoder().decode(base64Content)
    decodedKeystoreFile.writeBytes(keystoreBytes)
    
    // Load signing properties
    signingPropsFile.inputStream().use { keystoreProperties.load(it) }
    keystoreProperties["storeFile"] = decodedKeystoreFile.absolutePath
    
    println("✅ Keystore decoded and loaded successfully")
} else if (rootProject.file("key.properties").exists()) {
    // Fallback to local key.properties
    println("📝 Loading keystore from key.properties")
    keystoreProperties.load(FileInputStream(rootProject.file("key.properties")))
} else {
    println("⚠️  No keystore configuration found - using debug signing")
}

android {
    namespace = "com.echofort.echofort_mobile"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Signing configurations
    signingConfigs {
        create("release") {
            if (keystoreProperties.containsKey("storeFile")) {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = keystoreProperties["storeFile"]?.let { file(it.toString()) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    defaultConfig {
        applicationId = "com.echofort.echofort_mobile"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // ProGuard/R8 DISABLED for full functionality
            // APK will be larger (~70-80 MB) but everything will work correctly
            isMinifyEnabled = false
            isShrinkResources = false
            
            // ProGuard files kept for reference but not used
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
            
            // Use release signing configuration
            signingConfig = signingConfigs.getByName("release")
        }
        
        debug {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
