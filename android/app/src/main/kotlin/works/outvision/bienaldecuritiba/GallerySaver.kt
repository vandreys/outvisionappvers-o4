package works.outvision.bienaldecuritiba

import android.content.ContentValues
import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.os.Environment
import android.provider.MediaStore

/// Grava um bitmap em Pictures/OutVision. Compartilhado pelas duas views AR
/// (vídeo e modelo 3D), que capturam de formas diferentes mas salvam igual.
object GallerySaver {

    fun save(context: Context, bitmap: Bitmap): String {
        val isQPlus = Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, "outvision_${System.currentTimeMillis()}.jpg")
            put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
            if (isQPlus) {
                put(
                    MediaStore.Images.Media.RELATIVE_PATH,
                    "${Environment.DIRECTORY_PICTURES}/OutVision"
                )
                // Esconde o arquivo da galeria até a escrita terminar
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        }

        val resolver = context.contentResolver
        val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("MediaStore não aceitou a inserção")

        try {
            resolver.openOutputStream(uri).use { out ->
                checkNotNull(out) { "Stream de saída nulo" }
                if (!bitmap.compress(Bitmap.CompressFormat.JPEG, 95, out)) {
                    throw IllegalStateException("Falha ao comprimir JPEG")
                }
            }
        } catch (e: Exception) {
            resolver.delete(uri, null, null) // não deixa registro órfão na galeria
            throw e
        }

        if (isQPlus) {
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        }
        return uri.toString()
    }
}
