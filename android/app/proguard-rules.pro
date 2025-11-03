# ============================================================================
# ECHOFORT MOBILE - ULTRA CONSERVATIVE PROGUARD RULES
# Investment: ₹1+ Lakh - MUST WORK PERFECTLY
# Strategy: Preserve EVERYTHING, minimal optimization, maximum compatibility
# ============================================================================

# ============================================================================
# OPTIMIZATION SETTINGS - MINIMAL OPTIMIZATION
# ============================================================================
-optimizationpasses 1
-dontoptimize
-dontpreverify
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontskipnonpubliclibraryclassmembers
-verbose

# ============================================================================
# KEEP ALL ATTRIBUTES - CRITICAL FOR REFLECTION
# ============================================================================
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable
-keepattributes Exceptions
-keepattributes *JavascriptInterface*
-renamesourcefileattribute SourceFile

# ============================================================================
# FLUTTER FRAMEWORK - KEEP ABSOLUTELY EVERYTHING
# ============================================================================
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep interface io.flutter.** { *; }

# Keep Flutter's generated plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep Flutter activity and fragments
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.android.FlutterFragmentActivity { *; }
-keep class io.flutter.embedding.android.FlutterFragment { *; }

# Keep Flutter splash screen
-keep class io.flutter.embedding.android.SplashScreen { *; }
-keep class io.flutter.embedding.android.DrawableSplashScreen { *; }

# Keep Flutter assets
-keepclassmembers class * {
    @io.flutter.embedding.engine.plugins.FlutterPlugin$FlutterAssetManager *;
}

# ============================================================================
# ECHOFORT APPLICATION - KEEP EVERYTHING
# ============================================================================
-keep class com.echofort.** { *; }
-keep interface com.echofort.** { *; }
-keepclassmembers class com.echofort.** { *; }
-keepclasseswithmembers class com.echofort.** { *; }

# Keep MainActivity
-keep class com.echofort.echofort_mobile.MainActivity { *; }

# ============================================================================
# ANDROID RESOURCES - KEEP ALL
# ============================================================================
-keep class **.R
-keep class **.R$* { *; }
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep all drawable resources (splash screen, logo, icons)
-keep class * extends android.graphics.drawable.Drawable { *; }

# ============================================================================
# ANDROID FRAMEWORK COMPONENTS
# ============================================================================
-keep public class * extends android.app.Activity { *; }
-keep public class * extends android.app.Application { *; }
-keep public class * extends android.app.Service { *; }
-keep public class * extends android.content.BroadcastReceiver { *; }
-keep public class * extends android.content.ContentProvider { *; }
-keep public class * extends android.app.backup.BackupAgentHelper { *; }
-keep public class * extends android.preference.Preference { *; }

# Keep all views and their constructors
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public <init>(android.content.Context, android.util.AttributeSet, int, int);
    public void set*(...);
    *** get*();
}

# Keep custom views
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# ============================================================================
# ANDROIDX & MATERIAL DESIGN
# ============================================================================
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-keep class com.google.android.material.** { *; }
-dontwarn androidx.**

# ============================================================================
# KOTLIN - KEEP ALL
# ============================================================================
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Kotlin intrinsics
-keep class kotlin.jvm.internal.** { *; }

# Kotlin enums
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# ============================================================================
# NATIVE METHODS
# ============================================================================
-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclasseswithmembers class * {
    native <methods>;
}

# ============================================================================
# ENUMS - KEEP ALL
# ============================================================================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
    **[] $VALUES;
    public *;
}

# ============================================================================
# PARCELABLE & SERIALIZABLE
# ============================================================================
-keep class * implements android.os.Parcelable {
    public static final ** CREATOR;
    *;
}

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
    *;
}

# ============================================================================
# GSON / JSON SERIALIZATION
# ============================================================================
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep all fields with @SerializedName
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep all model classes
-keep class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ============================================================================
# NETWORKING - RETROFIT & OKHTTP
# ============================================================================
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }

# Retrofit annotations
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# ============================================================================
# WEBVIEW
# ============================================================================
-keep class android.webkit.** { *; }

-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
    public void *(android.webkit.WebView, java.lang.String);
}

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# ============================================================================
# GOOGLE PLAY SERVICES & FIREBASE
# ============================================================================
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**

# ============================================================================
# REFLECTION - KEEP ALL PUBLIC/PROTECTED MEMBERS
# ============================================================================
-keep public class * {
    public protected *;
}

-keepclassmembers class * {
    public <methods>;
    protected <methods>;
    public <fields>;
    protected <fields>;
}

# Keep all constructors
-keepclassmembers class * {
    public <init>(...);
    protected <init>(...);
}

# Keep all getters and setters
-keepclassmembers class * {
    void set*(***);
    void set*(int, ***);
    boolean is*();
    boolean is*(int);
    *** get*();
    *** get*(int);
}

# ============================================================================
# SECURITY & ENCRYPTION
# ============================================================================
-keep class javax.crypto.** { *; }
-keep class javax.security.** { *; }
-keep class java.security.** { *; }

# ============================================================================
# EXCEPTIONS & DEBUGGING
# ============================================================================
-keep public class * extends java.lang.Exception { *; }
-keep public class * extends java.lang.Error { *; }
-keep public class * extends java.lang.Throwable { *; }

# ============================================================================
# INTERFACES - KEEP ALL
# ============================================================================
-keep interface * { *; }

# ============================================================================
# SAFE WARNINGS ONLY
# ============================================================================
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**

# Google Play Core (if not used)
-dontwarn com.google.android.play.core.**

# Flutter deferred components (if not used)
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# ============================================================================
# FINAL SAFETY NET - KEEP EVERYTHING ELSE
# ============================================================================

# Keep all classes in main package
-keep class * { *; }

# Keep all interfaces
-keep interface * { *; }

# Keep all public/protected members of all classes
-keepclassmembers class * {
    public *;
    protected *;
}

# ============================================================================
# CRITICAL: DO NOT USE -ignorewarnings
# This was the root cause of previous issues
# ============================================================================

# ============================================================================
# END OF ULTRA CONSERVATIVE RULES
# ============================================================================
