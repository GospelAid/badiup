package com.gospelaid.badiup

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import android.media.ExifInterface
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val permissionCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE)

    if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
      ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE), permissionCode)
    } else {
      checkGallery()
    }

    GeneratedPluginRegistrant.registerWith(this)

    val channel = MethodChannel(flutterView, "/gallery")
    channel.setMethodCallHandler { call, result ->
      when (call.method) {
        "getItemCount" -> result.success(getGalleryImageCount())
        "getItem" -> {
          val index = (call.arguments as? Int) ?: 0
          dataForGalleryItem(index) { data, id, created, location ->
            result.success(mapOf<String, Any>(
                "data" to data,
                "id" to id,
                "created" to created,
                "location" to location
            ))
          }
        }
      }
    }
  }

  private fun checkGallery() {
    println("number of items ${getGalleryImageCount()}")
    dataForGalleryItem(0) { data, id, created, location ->
      println("first item $data $id $created $location")
    }
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
    if (requestCode == permissionCode
        && grantResults.isNotEmpty()
        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
      checkGallery()
    }
  }

  private fun dataForGalleryItem(index: Int, completion: (ByteArray, String, Int, String) -> Unit) {
    val uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
    val orderBy = MediaStore.Images.Media.DATE_TAKEN

    val cursor = contentResolver.query(uri, columns, null, null, "$orderBy DESC")
    cursor?.apply {
      moveToPosition(index)

      val idIndex = getColumnIndexOrThrow(MediaStore.Images.Media._ID)
      val dataIndex = getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
      val createdIndex = getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED)
      val latitudeIndex = getColumnIndexOrThrow(MediaStore.Images.Media.LATITUDE)
      val longitudeIndex = getColumnIndexOrThrow(MediaStore.Images.Media.LONGITUDE)

      val id = getString(idIndex)
      val filePath = getString(dataIndex)

      val file = File(filePath)
      val bmp = MediaStore.Images.Thumbnails.getThumbnail(contentResolver, id.toLong(), MediaStore.Images.Thumbnails.MINI_KIND, null)
      val stream = ByteArrayOutputStream()
      bmp.compress(Bitmap.CompressFormat.JPEG, 90, stream)
      val data = stream.toByteArray()

      val created = getInt(createdIndex)
      val latitude = getDouble(latitudeIndex)
      val longitude = getDouble(longitudeIndex)

      completion(data, id, created, "$latitude, $longitude")
    }
  }

  private val columns = arrayOf(
      MediaStore.Images.Media.DATA,
      MediaStore.Images.Media._ID,
      MediaStore.Images.Media.DATE_ADDED,
      MediaStore.Images.Media.LATITUDE,
      MediaStore.Images.Media.LONGITUDE)

  private fun getGalleryImageCount(): Int {
    val uri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI

    val cursor = contentResolver.query(uri, columns, null, null, null);

    return cursor?.count ?: 0
  }
}

