import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add this line
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.kevin.astral"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "28.2"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // 启用 core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
     // 添加 buildFeatures 配置
    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kevin.astral"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // 添加对多窗口模式的配置
        manifestPlaceholders["isResizeableActivity"] = "true"
    }

  signingConfigs {
      create("release") {
          keyAlias = keystoreProperties["keyAlias"] as String
          keyPassword = keystoreProperties["keyPassword"] as String
          storeFile = keystoreProperties["storeFile"]?.let { file(it) }
          storePassword = keystoreProperties["storePassword"] as String
      }
  }

    buildTypes {
        release {
          signingConfig = signingConfigs.getByName("release")
            //   signingConfig = signingConfigs.getByName("debug")

        }
    }

}

// 添加 dependencies 块
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // 添加对窗口模式的支持
    implementation("androidx.window:window:1.2.0-beta05")
    implementation("androidx.window:window-java:1.2.0-beta05")
    
    // add the Firebase SDK for Google Analytics
    implementation("com.google.firebase:firebase-analytics:17.4.1")
    // add SDKs for any other desired Firebase products
    // https://firebase.google.com/docs/android/setup#available-libraries
}

flutter {
    source = "../.."
}
