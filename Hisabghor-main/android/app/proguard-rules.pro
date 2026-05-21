## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class androidx.annotation.** { *; }
-keep class androidx.core.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

## Play Store Split Install
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.core.**

## Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.datatransport.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.storage.** { *; }
-keep class com.google.firebase.database.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

## Hive
-keep class com.hivemq.** { *; }
-keep class **$$__HiveType** { *; }
-keepclassmembers class * {
    @com.hiveflutter.** <fields>;
}
-keepclassmembers class * {
    @com.hive.** <fields>;
}
-keep class com.hiveflutter.adapters.HiveAdapter { *; }
-keep class com.hiveflutter.api.TypeAdapter { *; }
-dontwarn com.hiveflutter.**

## Google Sign In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.signin.** { *; }

## PDF & Printing
-keep class com.shockwave.** { *; }
-keep class org.apache.** { *; }
-dontwarn org.apache.**
-keep class com.itextpdf.** { *; }
-keep class com.lowagie.** { *; }
-dontwarn com.itextpdf.**
-dontwarn com.lowagie.**

## Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

## Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

## Local Auth
-keep class io.flutter.plugins.localauth.** { *; }
-keep class androidx.biometric.** { *; }
-keep class androidx.core.hardware.** { *; }

## Mobile Scanner
-keep class io.flutter.plugins.mobilescanner.** { *; }
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.mlkit.**

## File Picker
-keep class io.flutter.plugins.filepicker.** { *; }
-keep class io.github.ponnamkarthik.** { *; }

## Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

## URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

## Share Plus
-keep class io.flutter.plugins.share.** { *; }
-keep class io.flutter.plugins.shareplus.** { *; }

## Flutter Secure Storage
-keep class io.flutter.plugins.fluttersecurestorage.** { *; }

## SQLite
-keep class io.flutter.plugins.sqflite.** { *; }
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

## General
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes EnclosingMethod
-keepattributes InnerClasses

-dontwarn java.lang.invoke.MethodHandle
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn sun.misc.**
-dontwarn javax.annotation.**
-dontwarn kotlin.**
-dontwarn kotlinx.**

## Keep generated Hive files
-keep class * extends com.hive_flutter.adapters.HiveAdapter { *; }
-keep class * implements com.hive_flutter.api.TypeAdapter { *; }

## PDF & Printing additional rules
-keep class org.apache.pdfbox.** { *; }
-keep class org.apache.fontbox.** { *; }
-dontwarn org.apache.pdfbox.**
-dontwarn org.apache.fontbox.**
-keep class com.tom_roush.** { *; }
-dontwarn com.tom_roush.**

## Provider
-keep class androidx.lifecycle.LiveData** { *; }
-keep class androidx.lifecycle.MutableLiveData** { *; }
-keep class androidx.arch.core.** { *; }

## Google APIs
-keep class com.google.api.** { *; }
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-dontwarn com.google.api.**

## Excel
-keep class org.apache.poi.** { *; }
-dontwarn org.apache.poi.**
-keep class com.monitorjbl.xlsx.** { *; }
-dontwarn com.monitorjbl.xlsx.**

## HTTP & Networking
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

## Lottie
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**
