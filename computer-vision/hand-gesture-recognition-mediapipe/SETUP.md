# Setup Guide

Instructions for installing and running the project in a virtual environment.

## Prerequisites

- Python 3.11

## Installation

1. **Create a virtual environment**

   ```bash
   python3.11 -m venv venv
   ```

   On Windows with the Python Launcher:

   ```bash
   py -3.11 -m venv venv
   ```

2. **Activate the virtual environment**

   Linux / macOS:
   ```bash
   source venv/bin/activate
   ```

   Windows (Command Prompt):
   ```cmd
   venv\Scripts\activate
   ```

   Windows (PowerShell):
   ```powershell
   .\venv\Scripts\Activate.ps1
   ```

3. **Install dependencies**

   ```bash
   pip install "mediapipe==0.10.14" "tensorflow==2.16.2" "jax==0.4.26" "jaxlib==0.4.26" "numpy<2" "opencv-contrib-python<4.11" "opencv-python<4.11"
   ```

## Running the App

```bash
python app.py
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `--device` | Camera device number | `0` |
| `--width` | Camera capture width | `960` |
| `--height` | Camera capture height | `540` |
| `--use_static_image_mode` | Use static image mode for MediaPipe | off |
| `--min_detection_confidence` | Detection confidence threshold | `0.5` |
| `--min_tracking_confidence` | Tracking confidence threshold | `0.5` |

Example with a different camera:

```bash
python app.py --device 1
```
