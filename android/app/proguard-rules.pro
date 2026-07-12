# mobile_scanner (Bloque 5) usa ML Kit para leer QR/codigo de barras. Sus
# propias reglas consumer-proguard usan "com.google.mlkit.*" (un solo
# asterisco), que en ProGuard/R8 solo cubre clases directas del paquete, no
# subpaquetes. Eso deja fuera las clases internas que ML Kit resuelve por
# reflexion en tiempo de ejecucion, y R8 las renombra/elimina, causando un
# NullPointerException al abrir el escaner en release ("Attempt to invoke
# virtual method ... on a null object reference", con nombres ofuscados
# como g4.d/c4.c). Se cubre aqui con reglas recursivas ("**").
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_common.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.internal.mlkit_vision_barcode.**
