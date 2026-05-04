-keep class works.outvision.bienaldecuritiba.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.maps.android.** { *; }

# Google Play Services (base)
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-dontwarn com.google.android.gms.**

# ARCore
-keep class com.google.ar.core.** { *; }
-dontwarn com.google.ar.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ExoPlayer / Media3
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**