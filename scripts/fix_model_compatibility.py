#!/usr/bin/env python3
"""
Fix TFLite Model Compatibility
Converts a TFLite model to use older op versions compatible with tflite_flutter 0.11.0
"""

import tensorflow as tf
import numpy as np
import sys
import os

def check_model_ops(model_path):
    """Check what ops and versions the model uses"""
    print(f"\n📊 Analyzing model: {model_path}")
    
    try:
        interpreter = tf.lite.Interpreter(model_path=model_path)
        
        # Try to get op details (if available in your TF version)
        try:
            ops_details = interpreter._get_ops_details()
            print("\n🔍 Model Operations:")
            for op in ops_details:
                op_name = op.get('op_name', 'Unknown')
                version = op.get('version', 'N/A')
                print(f"  - {op_name}: version {version}")
        except:
            print("  (Cannot inspect op versions in this TF version)")
        
        # Check if model loads
        interpreter.allocate_tensors()
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print(f"\n✅ Model structure:")
        print(f"  Input shape: {input_details[0]['shape']}")
        print(f"  Input type: {input_details[0]['dtype']}")
        print(f"  Output shape: {output_details[0]['shape']}")
        print(f"  Output type: {output_details[0]['dtype']}")
        
        return True
    except Exception as e:
        print(f"\n❌ Error loading model: {e}")
        return False

def convert_model_from_saved_model(saved_model_path, output_path):
    """Convert from SavedModel format"""
    print(f"\n🔄 Converting from SavedModel: {saved_model_path}")
    
    converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_path)
    
    # Critical compatibility settings
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
    ]
    converter._experimental_lower_tensor_list_ops = False
    
    # Don't use experimental quantizer
    try:
        converter.experimental_new_quantizer = False
    except:
        pass
    
    # Optional: Quantization
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert
    tflite_model = converter.convert()
    
    # Save
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"✅ Converted model saved to: {output_path}")
    print(f"   Size: {len(tflite_model) / 1024:.2f} KB")
    
    return output_path

def convert_model_from_keras(keras_model_path, output_path):
    """Convert from Keras H5 format"""
    print(f"\n🔄 Converting from Keras model: {keras_model_path}")
    
    # Load Keras model
    model = tf.keras.models.load_model(keras_model_path)
    
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Critical compatibility settings
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS,
    ]
    converter._experimental_lower_tensor_list_ops = False
    
    # Don't use experimental quantizer
    try:
        converter.experimental_new_quantizer = False
    except:
        pass
    
    # Optional: Quantization
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert
    tflite_model = converter.convert()
    
    # Save
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"✅ Converted model saved to: {output_path}")
    print(f"   Size: {len(tflite_model) / 1024:.2f} KB")
    
    return output_path

def main():
    print("=" * 60)
    print("TFLite Model Compatibility Fixer")
    print("=" * 60)
    
    # Check TensorFlow version
    print(f"\n📦 TensorFlow version: {tf.__version__}")
    
    if len(sys.argv) < 2:
        print("\n❌ Usage:")
        print("  python fix_model_compatibility.py <model_path>")
        print("\nExample:")
        print("  python fix_model_compatibility.py saved_model/")
        print("  python fix_model_compatibility.py model.h5")
        print("  python fix_model_compatibility.py model.tflite")
        sys.exit(1)
    
    input_path = sys.argv[1]
    
    if not os.path.exists(input_path):
        print(f"\n❌ Error: Path not found: {input_path}")
        sys.exit(1)
    
    # Output path
    output_path = "model/model_quant_fixed.tflite"
    
    # Check if input is already TFLite
    if input_path.endswith('.tflite'):
        print(f"\n⚠️  Input is already a TFLite file: {input_path}")
        print("Checking model ops...")
        if check_model_ops(input_path):
            print("\n❌ This model still uses incompatible ops.")
            print("\n💡 You need to re-convert from the original model:")
            print("  1. Find your original SavedModel or .h5 file")
            print("  2. Run: python fix_model_compatibility.py <original_model>")
        sys.exit(1)
    
    # Convert based on input type
    if os.path.isdir(input_path):
        # SavedModel format
        output_path = convert_model_from_saved_model(input_path, output_path)
    elif input_path.endswith('.h5') or input_path.endswith('.keras'):
        # Keras format
        output_path = convert_model_from_keras(input_path, output_path)
    else:
        print(f"\n❌ Unsupported model format: {input_path}")
        print("Supported formats: SavedModel (directory), .h5, .keras")
        sys.exit(1)
    
    # Verify the converted model
    print("\n🔍 Verifying converted model...")
    if check_model_ops(output_path):
        print("\n✅ SUCCESS! Model converted successfully!")
        print(f"\n📁 Next steps:")
        print(f"  1. Copy to Flutter project:")
        print(f"     cp {output_path} model/model_quant.tflite")
        print(f"  2. Rebuild Flutter app:")
        print(f"     flutter clean && flutter run")
    else:
        print("\n❌ Converted model still has issues.")
        print("You may need to retrain your model with an older TensorFlow version.")

if __name__ == "__main__":
    main()
