# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Hive
-keep class com.hive.** { *; }
-dontwarn com.hive.**

# Keep all model classes
-keep class com.hisabghor_busines.myapp.** { *; }

# Google Play Core (suppress missing class warnings)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# OkHttp / HTTP
-dontwarn okhttp3.**
-dontwarn okio.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
