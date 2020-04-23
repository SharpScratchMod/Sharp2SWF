# Sharp2SWF

Sharp2SWF is a modification of Junebeetle's [Scratch 2 To SWF Converter](https://junebeetle.github.io/converter).
The modification makes the converter convert Sharp projects to SWF instead of Scratch projects.
This repository also includes a copy of Junebeetle's ["Create Projector" Workaround](https://junebeetle.github.io/projector) so you can easily create EXEs from your SWF file.

## Credits and stuff used by this

### Junebeetle's Scratch 2 To SWF Converter
**Type: _Slightly Modified, Included_**

The [Converter](Resources/Converter) part has been modified to use Gradle for building.
The [Loader](Resource/Loader) part has been modified to use .sharp files instead of .sb2 files.

The original build script is not included or used, as it only works on macOS because it is written in AppleScript.
The included build script with this is [Build.ps1](Build.ps1), which is a Windows PowerShell script.
This PowerShell script only works on Windows, although with some small tweaks you can probably easily get it working on macOS or Linux.

### Junebeetle's "Create Projector" Workaround
**Type: _Slightly Modified, Included_**

The [Projector](Resources/Projector) part has been modified to use Gradle for building.
A slight modification has been made to [Button.as](Resources/Projector/src/Button.as).
The modification was removing the `private var name` line, as this was causing a build failure.

The original build script is not included or used. [Build.ps1](Build.ps1) is also used for building this.

### Sharp Scratch Mod
**Type: _Slightly Modified by script, Downloaded by script_**

[Sharp](https://github.com/SharpScratchMod/Sharp) is a Scratch Mod created by Mrcomputer1 and algmwc5.

Scratch is created by the Scratch Team. See its website [here](https://scratch.mit.edu).

### Adopt OpenJDK (Java JDK)
**Type: _Unmodified, Downloaded by script_**

[Adopt OpenJDK](https://adoptopenjdk.net) is automatically downloaded by the script as it is required by Gradle.

### Git for Windows Portable
**Type: _Unmodified, Downloaded by script_**

[Git for Windows Portable](https://git-scm.com/download/win) is automatically downloaded by the script as it is used to download the Sharp source code.

### Python 3
**Type: _Unmodified, Downloaded by script_**

[Python 3](https://python.org) is automatically downloaded by the script as it is required by the script to run a Python script.

### Flash Player Projector
**Type: _Unmodified, Downloaded by script_**

[Flash Player Projector](https://www.adobe.com/support/flashplayer/debug_downloads.html) is optionally downloaded when running the script.
This file is required to build EXEs of the Converter and Projector files. And it is required to use Projector.

### Gradle
**Type: _Unmodified, Copied from Sharp_**

[Gradle](https://gradle.org) is used to build Sharp, the converter and the projector. It copies the Gradle Wrapper from Sharp to the Converter and Projector.

## Usage

### Getting and Using Build.ps1
1. Download the latest release's "Source Code" option from [here](https://github.com/SharpScratchMod/Sharp2SWF/releases).
2. Extract the zip.
3. Open the folder that contains Build.ps1.
4. Press File -> Open Windows PowerShell in File Explorer.
5. Type in `Set-ExecutionPolicy -Scope Process Bypass -Force` or there is a chance PowerShell will say that you cannot run custom/unknown scripts.
6. Type in `.\Build.ps1`
7. If prompted to get Flash Player Projector, choose option 1 (1 and enter)
8. Follow the steps below

### Building the converter
1. Once in .\Build.ps1's main menu, choose option 1.
2. Wait for it to say Complete. If you see any BUILD FAILURE or red error text, then there might be a bug.

### Building the projector
1. Once in .\Build.ps1's main menu, choose option 2.
2. Wait for it to say Complete. If you see any BUILD FAILURE or red error text, then there might be a bug.

### Building both
1. Once in .\Build.ps1's main menu, choose option 3.
2. Wait for it to say Complete. If you see any BUILD FAILURE or red error text, then there might be a bug.

### Creating an EXE
1. Open the Converter.exe.
2. Select your Sharp project.
3. Choose your options.
4. Select the convert button.
5. Enter a name for your SWF file.
6. Open the Projector.exe.
7. Select the Load Flash Player EXE button and select the flashplayer_32_sa.exe file the build script downloaded for you.
8. Select the Load SWF File button and select your SWF file you made with Converter.exe
9. Select Create Projector and choose a name for your EXE.

## Troubleshooting

### BUILD FAILURE/red error text
This is probably a bug, please report it.

### "File * cannot be loaded because running scripts is disabled on this system."
Type `Set-ExecutionPolicy -Scope Process Bypass -Force` into PowerShell before using `.\Build.ps1` to override this.

#### Description of what this does
`Set-ExecutionPolicy` is the PowerShell command to change the execution policy, which is what is restricting running the script as it is unknown.

`-Scope Process` makes it only change for this PowerShell session and revert when you close the PowerShell window.

`Bypass` is the execution policy, which allows the script to run.

`-Force` skips the "Press Y to confirm" screen.

### No `Converter.exe` or `Projector.exe`

You did not have the Flash Player Projector in the same folder as `.\Build.ps1`, with the name `flashplayer_32_sa.exe`.

Re-run the script and use option 1.