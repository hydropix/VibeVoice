# VibeVoice - Windows Installation Guide

This is a Windows-compatible fork of [Microsoft's VibeVoice](https://github.com/microsoft/VibeVoice), an open-source text-to-speech AI framework for generating expressive, long-form conversational audio.

## Changes from Original Repository

This fork includes the following Windows-specific fixes:
- **Path handling fix**: HuggingFace model IDs are now kept as strings instead of being converted to Windows paths (which would break `microsoft/VibeVoice-Realtime-0.5B` by converting `/` to `\`)

## System Requirements

### Minimum Requirements
- **OS**: Windows 10/11 (64-bit)
- **Python**: 3.9 or higher
- **RAM**: 8 GB minimum (16 GB recommended)
- **Storage**: 10 GB free space (for model and dependencies)

### Recommended for GPU Acceleration
- **NVIDIA GPU**: RTX 2060 or better
- **VRAM**: 6 GB minimum (8 GB+ recommended)
- **CUDA**: 11.8, 12.1, or 12.4

## Quick Installation

### Option 1: Automated Installation (Recommended)

1. **Download or clone this repository**:
   ```batch
   git clone https://github.com/hydropix/VibeVoice.git
   cd VibeVoice
   ```

2. **Run the installer**:
   - Double-click `install.bat`
   - Or run from command prompt:
     ```batch
     install.bat
     ```

3. **Follow the prompts** to:
   - Create a virtual environment
   - Select your CUDA version (if NVIDIA GPU detected)
   - Install all dependencies

4. **Run the demo**:
   - Double-click `run_demo.bat`
   - Open http://localhost:3000 in your browser

### Option 2: Manual Installation

1. **Install Python 3.9+**
   - Download from [python.org](https://www.python.org/downloads/)
   - **Important**: Check "Add Python to PATH" during installation

2. **Clone the repository**:
   ```batch
   git clone https://github.com/hydropix/VibeVoice.git
   cd VibeVoice
   ```

3. **Create a virtual environment**:
   ```batch
   python -m venv venv
   venv\Scripts\activate
   ```

4. **Install PyTorch** (choose one based on your GPU):

   For NVIDIA GPU with CUDA 12.4:
   ```batch
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
   ```

   For NVIDIA GPU with CUDA 12.1:
   ```batch
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
   ```

   For NVIDIA GPU with CUDA 11.8:
   ```batch
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
   ```

   For CPU only:
   ```batch
   pip install torch torchvision torchaudio
   ```

5. **Install VibeVoice**:
   ```batch
   pip install -e .
   ```

## Running VibeVoice

### Web Demo (Recommended)

Start the web server:
```batch
venv\Scripts\activate
python demo\vibevoice_realtime_demo.py --device cuda --port 3000
```

Then open http://localhost:3000 in your browser.

**Available parameters**:
- `--model_path`: Model to use (default: `microsoft/VibeVoice-Realtime-0.5B`)
- `--device`: `cuda`, `cpu` (default: `cuda`)
- `--port`: Server port (default: `3000`)

### Command Line Inference

Generate speech from a text file:
```batch
venv\Scripts\activate
python demo\realtime_model_inference_from_file.py ^
    --model_path microsoft/VibeVoice-Realtime-0.5B ^
    --txt_path demo\text_examples\1p_vibevoice.txt ^
    --speaker_name Carter ^
    --device cuda
```

**Available speakers**:
- `Carter` (male, English)
- `Davis` (male, English)
- `Emma` (female, English)
- `Frank` (male, English)
- `Grace` (female, English)
- `Mike` (male, English)
- `Samuel` (male, Indian English)

## Configuration Options

### Environment Variables

You can set these environment variables before running:

| Variable | Description | Default |
|----------|-------------|---------|
| `MODEL_PATH` | HuggingFace model ID or local path | `microsoft/VibeVoice-Realtime-0.5B` |
| `MODEL_DEVICE` | Device to run on (`cuda`/`cpu`) | `cuda` |
| `VOICE_PRESET` | Default voice preset | First available |

### API Parameters

When using the WebSocket API (`/stream`), you can pass:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `text` | Text to synthesize | (required) |
| `voice` | Voice preset name | Default voice |
| `cfg` | CFG scale (guidance strength) | `1.5` |
| `steps` | Inference steps | `5` |

## Troubleshooting

### "Python is not recognized"

- Reinstall Python and check "Add Python to PATH"
- Or manually add Python to your system PATH

### "CUDA is not available"

1. Check if you have an NVIDIA GPU:
   ```batch
   nvidia-smi
   ```

2. Install/update NVIDIA drivers from [nvidia.com](https://www.nvidia.com/download/index.aspx)

3. Reinstall PyTorch with the correct CUDA version:
   ```batch
   pip uninstall torch torchvision torchaudio
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
   ```

### "Out of memory" errors

- Try reducing inference steps:
  ```batch
  python demo\vibevoice_realtime_demo.py --device cuda
  ```
  Then use fewer steps in the web interface

- Or use CPU (slower but uses system RAM):
  ```batch
  python demo\vibevoice_realtime_demo.py --device cpu
  ```

### Model download issues

The model (~3GB) is downloaded automatically on first run. If download fails:

1. Check your internet connection
2. Try again (downloads resume automatically)
3. Manually download from [HuggingFace](https://huggingface.co/microsoft/VibeVoice-Realtime-0.5B)

### "transformers version" warnings

This project is optimized for `transformers==4.51.3`. If you see compatibility warnings, reinstall:
```batch
pip install transformers==4.51.3
```

## Performance Tips

1. **Use GPU** if available - significantly faster than CPU
2. **Reduce inference steps** for faster (but lower quality) output
3. **Close other GPU applications** to free VRAM
4. **Use shorter text inputs** for testing

## Project Structure

```
VibeVoice/
├── install.bat              # Windows installer
├── run_demo.bat             # Quick demo launcher (created by installer)
├── WINDOWS_SETUP.md         # This file
├── demo/
│   ├── web/
│   │   ├── app.py           # FastAPI web server (Windows-patched)
│   │   └── index.html       # Web interface
│   ├── voices/              # Voice presets
│   └── text_examples/       # Sample texts
├── vibevoice/               # Main package
└── pyproject.toml           # Package configuration
```

## Links

- **This Fork**: https://github.com/hydropix/VibeVoice
- **Original Repository**: https://github.com/microsoft/VibeVoice
- **HuggingFace Model**: https://huggingface.co/microsoft/VibeVoice-Realtime-0.5B
- **Technical Report**: https://arxiv.org/pdf/2508.19205

## License

MIT License - See [LICENSE](LICENSE) file.

## Credits

- Original VibeVoice by Microsoft Research
- Windows compatibility fixes by hydropix
