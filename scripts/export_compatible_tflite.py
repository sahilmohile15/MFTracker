"""
Export TFLite models with ops version 11 compatibility for Flutter app.

This script converts your trained TensorFlow/Keras models to TFLite format
with FULLY_CONNECTED ops version 11 (instead of v12) to work with older TFLite runtimes.

IMPORTANT: The issue is that your models were exported with TensorFlow 2.16+ which uses
FULLY_CONNECTED v12, but tflite_flutter plugin uses an older runtime that only supports v11.

SOLUTION: Use TensorFlow 2.15 or earlier to export models, OR use specific converter settings.
"""

import tensorflow as tf
import numpy as np
import sys

print(f"TensorFlow version: {tf.__version__}")
print(f"TensorFlow location: {tf.__file__}")

# Check TensorFlow version
tf_version = tuple(map(int, tf.__version__.split('.')[:2]))
if tf_version >= (2, 16):
    print("\n⚠️  WARNING: TensorFlow 2.16+ uses FULLY_CONNECTED v12")
    print("⚠️  Your Flutter app needs v11 or earlier")
    print("\n🔧 SOLUTIONS:")
    print("1. Downgrade TensorFlow: pip install tensorflow==2.15.0")
    print("2. OR use experimental_new_quantizer=False flag")
    print("3. OR rebuild tflite_flutter with newer runtime")
    print()

def convert_model_to_tflite(model_path, output_path, model_type="keras"):
    """
    Convert a model to TFLite with ops v11 compatibility.
    
    Args:
        model_path: Path to .h5, .keras, or SavedModel directory
        output_path: Path for output .tflite file
        model_type: "keras" or "saved_model"
    """
    print(f"\n{'='*60}")
    print(f"Converting: {model_path}")
    print(f"Output: {output_path}")
    print(f"{'='*60}\n")
    
    # Load model
    if model_type == "keras":
        print("Loading Keras model...")
        model = tf.keras.models.load_model(model_path)
        print(f"Model loaded: {model.name}")
        model.summary()
    else:
        print("Loading SavedModel...")
        model = model_path  # Will be converted directly
    
    # Create converter
    if model_type == "keras":
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
    else:
        converter = tf.lite.TFLiteConverter.from_saved_model(model_path)
    
    # CRITICAL SETTINGS for ops v11 compatibility
    print("\nConverter settings:")
    
    # Option 1: Disable new quantizer (may help with v12 → v11)
    if hasattr(converter, 'experimental_new_quantizer'):
        converter.experimental_new_quantizer = False
        print("✓ experimental_new_quantizer = False")
    
    # Option 2: Use basic optimizations only
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    print("✓ optimizations = [DEFAULT]")
    
    # Option 3: Target older ops (if available)
    if hasattr(converter, 'target_spec'):
        # Try to force older ops version
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS  # Use built-in ops only
        ]
        print("✓ target_spec.supported_ops = [TFLITE_BUILTINS]")
    
    # Option 4: Disable experimental features
    if hasattr(converter, 'experimental_new_converter'):
        converter.experimental_new_converter = False
        print("✓ experimental_new_converter = False")
    
    # Convert
    print("\nConverting model...")
    try:
        tflite_model = converter.convert()
        print(f"✅ Conversion successful! Size: {len(tflite_model) / 1024:.2f} KB")
    except Exception as e:
        print(f"❌ Conversion failed: {e}")
        return False
    
    # Save
    print(f"\nSaving to: {output_path}")
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    print("✅ Model saved successfully!")
    
    # Verify ops version
    print("\nVerifying ops version...")
    try:
        interpreter = tf.lite.Interpreter(model_path=output_path)
        ops_details = interpreter._get_ops_details()
        
        fc_ops = [op for op in ops_details if 'FULLY_CONNECTED' in str(op.get('op_name', ''))]
        if fc_ops:
            print(f"Found {len(fc_ops)} FULLY_CONNECTED ops:")
            for i, op in enumerate(fc_ops[:3]):  # Show first 3
                version = op.get('version', 'unknown')
                print(f"  Op {i+1}: version = {version}")
                if version == 12:
                    print("    ⚠️  WARNING: Still using v12!")
                elif version == 11:
                    print("    ✅ Compatible with v11!")
        else:
            print("No FULLY_CONNECTED ops found (model might be using other ops)")
        
        # Show all op types
        op_types = {}
        for op in ops_details:
            op_name = op.get('op_name', 'UNKNOWN')
            version = op.get('version', 0)
            key = f"{op_name}_v{version}"
            op_types[key] = op_types.get(key, 0) + 1
        
        print(f"\nAll ops in model ({len(op_types)} unique):")
        for op_key, count in sorted(op_types.items()):
            print(f"  {op_key}: {count}x")
            
    except Exception as e:
        print(f"⚠️  Could not verify ops: {e}")
    
    return True


def main():
    print("\n" + "="*60)
    print("TFLite Model Exporter - Ops v11 Compatibility")
    print("="*60)
    
    # Example usage - MODIFY THESE PATHS
    models_to_convert = [
        # Classifier model
        {
            "input": "path/to/your/classifier_model.h5",  # or .keras
            "output": "model/classifier_model.tflite",
            "type": "keras"
        },
        # NER model
        {
            "input": "path/to/your/ner_model.h5",  # or .keras
            "output": "model/ner_model.tflite",
            "type": "keras"
        }
    ]
    
    print("\n📝 INSTRUCTIONS:")
    print("1. Update the paths in models_to_convert[] above")
    print("2. Make sure you have your .h5 or .keras model files")
    print("3. Run: python scripts/export_compatible_tflite.py")
    print("\n💡 TIP: If still getting v12 errors:")
    print("   pip install tensorflow==2.15.0")
    print("   Then re-run this script")
    print()
    
    # Check if models exist
    import os
    for model_config in models_to_convert:
        input_path = model_config["input"]
        if not os.path.exists(input_path):
            print(f"❌ Model not found: {input_path}")
            print(f"   Please update the path in this script")
            return
    
    # Convert all models
    success_count = 0
    for model_config in models_to_convert:
        success = convert_model_to_tflite(
            model_config["input"],
            model_config["output"],
            model_config["type"]
        )
        if success:
            success_count += 1
        print()
    
    print("="*60)
    print(f"Conversion complete: {success_count}/{len(models_to_convert)} successful")
    print("="*60)
    
    if success_count == len(models_to_convert):
        print("\n✅ All models converted successfully!")
        print("\n📱 Next steps:")
        print("1. Hot restart your Flutter app (press 'R' in terminal)")
        print("2. Navigate to Settings → Import from SMS")
        print("3. Check logs for successful model loading")
    else:
        print("\n⚠️  Some conversions failed")
        print("Check the errors above and try:")
        print("1. pip install tensorflow==2.15.0")
        print("2. Re-run this script")


if __name__ == "__main__":
    # Quick check of existing models
    import os
    import glob
    
    model_dir = "model"
    if os.path.exists(model_dir):
        tflite_files = glob.glob(os.path.join(model_dir, "*.tflite"))
        print(f"\nFound {len(tflite_files)} .tflite files in {model_dir}/:")
        for f in tflite_files:
            size = os.path.getsize(f) / 1024
            print(f"  - {os.path.basename(f)} ({size:.2f} KB)")
    
    print("\n" + "="*60)
    print("⚠️  CURRENT STATUS")
    print("="*60)
    print("Your models are using FULLY_CONNECTED v12")
    print("Flutter app requires v11 or earlier")
    print("\n🔧 FIX OPTIONS:")
    print()
    print("OPTION 1: Downgrade TensorFlow (RECOMMENDED)")
    print("  pip install tensorflow==2.15.0")
    print("  python scripts/export_compatible_tflite.py")
    print()
    print("OPTION 2: Update tflite_flutter plugin")
    print("  (Requires plugin source modification - complex)")
    print()
    print("OPTION 3: Use TensorFlow Lite Model Maker")
    print("  pip install tflite-model-maker")
    print("  (Automatically handles compatibility)")
    print()
    print("=" * 60)
    print("\n💡 Uncomment main() call below after updating model paths")
    
    # Uncomment to run conversion:
    # main()
