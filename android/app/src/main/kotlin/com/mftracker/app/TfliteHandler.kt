package com.mftracker.app

import android.content.Context
import android.content.res.AssetManager
import org.tensorflow.lite.Interpreter
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.MappedByteBuffer
import java.nio.channels.FileChannel

class TfliteHandler(private val context: Context) {
    private var classifierInterpreter: Interpreter? = null
    private var nerInterpreter: Interpreter? = null

    fun initialize(): Boolean {
        return try {
            // Load classifier model
            val classifierModel = loadModelFile("model/classifier_model.tflite")
            classifierInterpreter = Interpreter(classifierModel)
            
            // Load NER model
            val nerModel = loadModelFile("model/ner_model.tflite")
            nerInterpreter = Interpreter(nerModel)
            
            true
        } catch (e: Exception) {
            android.util.Log.e("TfliteHandler", "Error loading models: ${e.message}", e)
            false
        }
    }

    fun classifySMS(tokens: IntArray): FloatArray? {
        if (classifierInterpreter == null || tokens.size != 128) {
            android.util.Log.e("TfliteHandler", "Classifier not initialized or invalid input size: ${tokens.size}")
            return null
        }

        return try {
            // Prepare input: reshape to [1, 128]
            val input = Array(1) { IntArray(128) }
            for (i in 0 until 128) {
                input[0][i] = tokens[i]
            }

            // Prepare output: [1, 2] for binary classification
            val output = Array(1) { FloatArray(2) }

            // Run inference
            classifierInterpreter!!.run(input, output)

            // Return probabilities
            output[0]
        } catch (e: Exception) {
            android.util.Log.e("TfliteHandler", "Error during classification: ${e.message}", e)
            null
        }
    }

    fun extractEntities(tokens: IntArray): FloatArray? {
        if (nerInterpreter == null || tokens.size != 256) {
            android.util.Log.e("TfliteHandler", "NER not initialized or invalid input size: ${tokens.size}")
            return null
        }

        return try {
            // Prepare input: reshape to [1, 256]
            val input = Array(1) { IntArray(256) }
            for (i in 0 until 256) {
                input[0][i] = tokens[i]
            }

            // Prepare output: [1, 256, 11] for NER (11 labels per token)
            val output = Array(1) { Array(256) { FloatArray(11) } }

            // Run inference
            nerInterpreter!!.run(input, output)

            // Flatten output to 1D array [256 * 11 = 2816 elements]
            val flatOutput = FloatArray(256 * 11)
            var index = 0
            for (i in 0 until 256) {
                for (j in 0 until 11) {
                    flatOutput[index++] = output[0][i][j]
                }
            }

            flatOutput
        } catch (e: Exception) {
            android.util.Log.e("TfliteHandler", "Error during NER: ${e.message}", e)
            null
        }
    }

    private fun loadModelFile(modelPath: String): MappedByteBuffer {
        val fileDescriptor = context.assets.openFd(modelPath)
        val inputStream = FileInputStream(fileDescriptor.fileDescriptor)
        val fileChannel = inputStream.channel
        val startOffset = fileDescriptor.startOffset
        val declaredLength = fileDescriptor.declaredLength
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength)
    }

    fun close() {
        classifierInterpreter?.close()
        nerInterpreter?.close()
    }
}
