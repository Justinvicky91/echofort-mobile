# ========================================
# EchoFort Mobile - ProGuard Rules (FIXED)
# ========================================
# This configuration preserves critical app components
# while still providing code obfuscation and size reduction

# ========================================
# Flutter Core - MUST KEEP
# ========================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Flutter assets and resources
-keepclassmembers class * {
    @io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterAssetManager *;
}

# ========================================
# EchoFort Application - MUST KEEP
# ========================================
-keep class com.echofort.** { *; }
-keepclassmembers class com.echofort.** { *; }
-keepattributes *Annotation*

# Keep all resources (splash screen, logo, etc.)
-keepclassmembers class **.R$* {
    public static <fields>;
}
-keep class **.R$*

# ========================================
# Android Core Components
# ========================================
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Keep custom views and their constructors
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# ========================================
# AndroidX and Material Design
# ========================================
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-keep class com.google.android.material.** { *; }
-dontwarn androidx.**
-dontwarn com.google.android.material.**

# ========================================
# Google Play Services & Firebase
# ========================================
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ========================================
# Gson (JSON serialization)
# ========================================
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep data model classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ========================================
# Retrofit & OkHttp (Networking)
# ========================================
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep interface okhttp3.** { *; }
-keep interface retrofit2.** { *; }

# Retrofit annotations
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

# ========================================
# Kotlin
# ========================================
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# ========================================
# Native Methods
# ========================================
-keepclasseswithmembernames class * {
    native <methods>;
}

# ========================================
# Enums
# ========================================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
    **[] $VALUES;
    public *;
}

# ========================================
# Parcelable & Serializable
# ========================================
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ========================================
# WebView
# ========================================
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String);
}

# ========================================
# Security & Encryption
# ========================================
-keep class javax.crypto.** { *; }
-keep class javax.security.** { *; }

# ========================================
# Debugging & Stack Traces
# ========================================
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
-keepattributes *Annotation*,Signature,Exception

# Keep exception classes
-keep public class * extends java.lang.Exception

# ========================================
# Optimization Settings
# ========================================
-optimizationpasses 3
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

# ========================================
# Logging (Remove in release)
# ========================================
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}

# ========================================
# Google Play Core (Flutter deferred components)
# ========================================
# Only warn about missing classes, don't fail the build
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Flutter deferred components (if not used)
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager$FeatureInstallStateUpdatedListener

# ========================================
# IMPORTANT: DO NOT USE -ignorewarnings
# ========================================
# Using -ignorewarnings causes R8 to be too aggressive
# and removes code that the app actually needs.
# Instead, we use specific -dontwarn rules above.

# End of ProGuard rules
