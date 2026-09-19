markdown
# FishNet AI 🐟📱

**FishNet AI** is a cross-platform mobile application built with **Flutter** and **TensorFlow Lite (TFLite)** designed for real-time, on-device fish species recognition and diagnostics[cite: 3]. By leveraging edge AI, the app delivers low-latency predictions without requiring continuous cloud connectivity[cite: 3].

---

## 🌟 Key Features

* **On-Device Inference:** Integrated TensorFlow Lite (`.tflite`) model for fast, offline prediction[cite: 3].
* **Transfer Learning Architecture:** Trained using a **ResNet50** backbone for accurate species classification[cite: 3].
* **Real-Time Input:** Capture images via live camera feed or select existing photos from the device gallery.
* **Cross-Platform Support:** Built with Flutter to ensure seamless performance on mobile devices[cite: 3].

---

## 🏗️ System Architecture & Workflow




[ Research & Model Training ]
Dataset -> ResNet50 (Transfer Learning) -> Model Evaluation -> TFLite Quantization (.tflite)
|
v
[ Mobile Application (Flutter) ]
User Image / Camera -> Image Preprocessing -> TFLite Interpreter -> Classification Output





## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)[cite: 3]
* **Machine Learning:** TensorFlow / Keras (Python)[cite: 3]
* **Edge Deployment:** TensorFlow Lite (TFLite)[cite: 3]
* **Model Architecture:** ResNet50[cite: 3]

---

## 📁 Repository Structure


├── assets/
│   ├── models/
│   │   ├── fish_model.tflite       # Quantized TFLite model file
│   │   └── labels.txt              # Class labels corresponding to model output
│   └── images/                     # App assets & icons
├── lib/
│   ├── main.dart                   # Application entry point
│   ├── screens/                    # UI screens (Home, Camera, Result)
│   └── services/                   # TFLite helper & image pre-processing modules
├── pubspec.yaml                    # Dependencies and asset declarations
└── README.md





## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0.0 or higher)
* [Android Studio](https://developer.android.com/studio) / VS Code with Flutter extension
* Java Development Kit (JDK 11 or higher)
* An Android device or emulator (API 21+)

### Installation

1. **Clone the Repository:**

git clone [https://github.com/rudramadhabofficial/fishnet-ai.git](https://github.com/rudramadhabofficial/fishnet-ai.git)
cd fishnet-ai


2. **Install Dependencies:**

flutter pub get




3. **Verify Asset Configuration:**
Ensure your `pubspec.yaml` includes the model files:

flutter:
  assets:
    - assets/models/fish_model.tflite
    - assets/models/labels.txt




4. **Run the App:**
Connect your physical device or start an emulator, then execute:

flutter run







## 🔬 Model Training Details

* **Base Model:** ResNet50 pre-trained on ImageNet.


* **Pipeline:** End-to-end research-to-production pipeline covering data cleaning, augmentation, fine-tuning, and model quantization.


* **Conversion:** Exported to flatbuffer format (`.tflite`) for mobile hardware optimization.





## 👨‍💻 Author

**Rudra Madhab Mishra**
