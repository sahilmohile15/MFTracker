# TensorFlow Lite ProGuard rules
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

-dontwarn org.tensorflow.lite.**
-dontwarn org.tensorflow.lite.gpu.**
