@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: VibeVoice Windows Installation Script
:: Fork: https://github.com/hydropix/VibeVoice
:: Original: https://github.com/microsoft/VibeVoice
:: ============================================================================

title VibeVoice Windows Installer

echo.
echo ============================================================================
echo                     VibeVoice Windows Installation
echo                     Text-to-Speech AI Framework
echo ============================================================================
echo.

:: Check if running as administrator (recommended but not required)
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] Running with administrator privileges
) else (
    echo [INFO] Running without administrator privileges
    echo [INFO] If installation fails, try running as administrator
)
echo.

:: ============================================================================
:: Check Python Installation
:: ============================================================================
echo [1/7] Checking Python installation...

where python >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH
    echo.
    echo Please install Python 3.9 or higher from:
    echo https://www.python.org/downloads/
    echo.
    echo IMPORTANT: During installation, check "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

:: Get Python version
for /f "tokens=2 delims= " %%v in ('python --version 2^>^&1') do set PYTHON_VERSION=%%v
echo [OK] Python %PYTHON_VERSION% found

:: Check Python version is >= 3.9
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set MAJOR=%%a
    set MINOR=%%b
)
if %MAJOR% LSS 3 (
    echo [ERROR] Python 3.9+ required, found Python %PYTHON_VERSION%
    pause
    exit /b 1
)
if %MAJOR% EQU 3 if %MINOR% LSS 9 (
    echo [ERROR] Python 3.9+ required, found Python %PYTHON_VERSION%
    pause
    exit /b 1
)
echo.

:: ============================================================================
:: Check pip
:: ============================================================================
echo [2/7] Checking pip...

python -m pip --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [INFO] pip not found, installing...
    python -m ensurepip --upgrade
)
echo [OK] pip is available
echo.

:: ============================================================================
:: Create Virtual Environment
:: ============================================================================
echo [3/7] Setting up virtual environment...

set VENV_DIR=%~dp0venv

if exist "%VENV_DIR%" (
    echo [INFO] Virtual environment already exists at %VENV_DIR%
    choice /C YN /M "Do you want to recreate it? (This will delete existing environment)"
    if !errorLevel! EQU 1 (
        echo [INFO] Removing existing virtual environment...
        rmdir /s /q "%VENV_DIR%"
        echo [INFO] Creating new virtual environment...
        python -m venv "%VENV_DIR%"
    ) else (
        echo [INFO] Using existing virtual environment
    )
) else (
    echo [INFO] Creating virtual environment...
    python -m venv "%VENV_DIR%"
)

if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo [ERROR] Failed to create virtual environment
    pause
    exit /b 1
)
echo [OK] Virtual environment ready
echo.

:: ============================================================================
:: Activate Virtual Environment
:: ============================================================================
echo [4/7] Activating virtual environment...
call "%VENV_DIR%\Scripts\activate.bat"
echo [OK] Virtual environment activated
echo.

:: ============================================================================
:: Upgrade pip
:: ============================================================================
echo [5/7] Upgrading pip...
python -m pip install --upgrade pip
echo [OK] pip upgraded
echo.

:: ============================================================================
:: Install PyTorch with CUDA support
:: ============================================================================
echo [6/7] Installing PyTorch...
echo.

:: Check for NVIDIA GPU
nvidia-smi >nul 2>&1
if %errorLevel% EQU 0 (
    echo [INFO] NVIDIA GPU detected
    echo [INFO] Installing PyTorch with CUDA support...
    echo.
    echo Choose CUDA version:
    echo   1. CUDA 12.4 (Recommended for RTX 30xx/40xx series)
    echo   2. CUDA 12.1
    echo   3. CUDA 11.8 (For older GPUs)
    echo   4. CPU only (No GPU acceleration)
    echo.
    choice /C 1234 /M "Select option"

    if !errorLevel! EQU 1 (
        echo [INFO] Installing PyTorch with CUDA 12.4...
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
    ) else if !errorLevel! EQU 2 (
        echo [INFO] Installing PyTorch with CUDA 12.1...
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    ) else if !errorLevel! EQU 3 (
        echo [INFO] Installing PyTorch with CUDA 11.8...
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    ) else (
        echo [INFO] Installing PyTorch CPU version...
        pip install torch torchvision torchaudio
    )
) else (
    echo [INFO] No NVIDIA GPU detected, installing CPU version of PyTorch...
    pip install torch torchvision torchaudio
)

if %errorLevel% neq 0 (
    echo [ERROR] Failed to install PyTorch
    pause
    exit /b 1
)
echo [OK] PyTorch installed
echo.

:: ============================================================================
:: Install VibeVoice and dependencies
:: ============================================================================
echo [7/7] Installing VibeVoice and dependencies...
echo.

:: Install the package in editable mode
pip install -e "%~dp0."

if %errorLevel% neq 0 (
    echo [ERROR] Failed to install VibeVoice
    pause
    exit /b 1
)

echo [OK] VibeVoice installed successfully
echo.

:: ============================================================================
:: Verify Installation
:: ============================================================================
echo ============================================================================
echo                        Verifying Installation
echo ============================================================================
echo.

echo [INFO] Checking PyTorch...
python -c "import torch; print(f'PyTorch version: {torch.__version__}')"
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
python -c "import torch; print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}')"
if %errorLevel% neq 0 (
    echo [WARNING] PyTorch verification had issues
)
echo.

echo [INFO] Checking VibeVoice...
python -c "from vibevoice.processor.vibevoice_streaming_processor import VibeVoiceStreamingProcessor; print('VibeVoice import: OK')"
if %errorLevel% neq 0 (
    echo [WARNING] VibeVoice verification had issues
)
echo.

:: ============================================================================
:: Create Run Scripts
:: ============================================================================
echo [INFO] Creating convenience scripts...

:: Create run_demo.bat
(
echo @echo off
echo setlocal
echo.
echo :: Activate virtual environment
echo call "%%~dp0venv\Scripts\activate.bat"
echo.
echo :: Set default values
echo set MODEL_PATH=microsoft/VibeVoice-Realtime-0.5B
echo set PORT=3000
echo.
echo :: Check for CUDA
echo python -c "import torch; exit(0 if torch.cuda.is_available() else 1)" 2^>nul
echo if %%errorLevel%% EQU 0 ^(
echo     set DEVICE=cuda
echo ^) else ^(
echo     set DEVICE=cpu
echo ^)
echo.
echo echo.
echo echo ============================================================================
echo echo                        VibeVoice Demo Server
echo echo ============================================================================
echo echo.
echo echo Model: %%MODEL_PATH%%
echo echo Device: %%DEVICE%%
echo echo Port: %%PORT%%
echo echo.
echo echo Starting server... ^(First run will download the model, ~3GB^)
echo echo Once started, open: http://localhost:%%PORT%%
echo echo.
echo echo Press Ctrl+C to stop the server
echo echo.
echo.
echo python "%%~dp0demo\vibevoice_realtime_demo.py" --model_path "%%MODEL_PATH%%" --device "%%DEVICE%%" --port %%PORT%%
echo.
echo pause
) > "%~dp0run_demo.bat"

echo [OK] Created run_demo.bat
echo.

:: ============================================================================
:: Installation Complete
:: ============================================================================
echo.
echo ============================================================================
echo                     Installation Complete!
echo ============================================================================
echo.
echo Next steps:
echo.
echo   1. Run the demo:
echo      - Double-click "run_demo.bat"
echo      - Or run: python demo\vibevoice_realtime_demo.py
echo.
echo   2. Open in browser:
echo      http://localhost:3000
echo.
echo   3. First run will download the model (~3GB)
echo.
echo For more information, see WINDOWS_SETUP.md
echo.
echo ============================================================================
echo.

pause
