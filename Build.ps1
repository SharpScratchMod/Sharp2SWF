$JavaJDKURL = "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u252-b09/OpenJDK8U-jdk_x64_windows_hotspot_8u252b09.zip"
$JavaJDKDir = (Resolve-Path ".").Path + "\temp\java\jdk8u252-b09\bin"

$PortableGitURL = "https://github.com/git-for-windows/git/releases/download/v2.26.2.windows.1/PortableGit-2.26.2-64-bit.7z.exe"
$PortableGitDir = (Resolve-Path ".").Path + "\temp\PortableGit\bin"

$Python3URL = "https://www.python.org/ftp/python/3.8.2/python-3.8.2-embed-amd64.zip"
$Python3Dir = (Resolve-Path ".").Path + "\temp\python"

$FPProjectorURL = "https://fpdownload.macromedia.com/pub/flashplayer/updaters/32/flashplayer_32_sa.exe"

$OrigPath = $env:PATH

If(-Not (Test-Path -Path .\temp)){
	New-Item -Path . -Name "temp" -ItemType "directory" | Out-Null
	New-Item -Path .\temp -Name "DeleteMeIfYouWant.txt" -ItemType "file" -Value "You may delete this folder if you want, just it will take longer to run Build.ps1 again." | Out-Null
}

function Script:Utility-JavaJDKPrepare{
	if(-Not (Test-Path -Path $JavaJDKDir)){
		Write-Output "[Java] Downloading known supported Java version..."
		
		Invoke-WebRequest $JavaJDKURL -OutFile .\temp\java.zip
		Expand-Archive -Path .\temp\java.zip -DestinationPath .\temp\java
		Remove-Item .\temp\java.zip
		
		$env:PATH = "$($JavaJDKDir);$($env:PATH)"
	}Else{
		Write-Output "[Java] Detected Java install in temp directory! Using it..."
		
		$env:PATH = "$($JavaJDKDir);$($env:PATH)"
	}
}

function Script:Utility-GitPortablePrepare{
	if(-Not (Test-Path -Path $PortableGitDir)){
		Write-Output "[Git] Downloading portable Git..."
		
		Invoke-WebRequest $PortableGitURL -OutFile .\temp\portablegit.exe
		Start-Process -FilePath .\temp\portablegit.exe -WorkingDirectory .\temp -NoNewWindow -Wait -ArgumentList "-y"
		Remove-Item .\temp\portablegit.exe
		
		$env:PATH = "$($PortableGitDir);$($env:PATH)"
	}else{
		Write-Output "[Git] Detected Git install in temp directory! Using it..."
		
		$env:PATH = "$($PortableGitDir);$($env:PATH)"
	}
}

function Script:Utility-Python3Prepare{
	if(-Not (Test-Path -Path $Python3Dir)){
		Write-Output "[Python] Downloading known supported Python 3..."
		
		Invoke-WebRequest $Python3URL -OutFile .\temp\python3.zip
		Expand-Archive -Path .\temp\python3.zip -DestinationPath .\temp\python
		Remove-Item .\temp\python3.zip
		
		$env:PATH = "$($Python3Dir);$($env:PATH)"
	}else{
		Write-Output "[Python] Detected Python install in temp directory! Using it..."
		
		$env:PATH = "$($Python3Dir);$($env:PATH)"
	}
}

function Script:Utility-FlashProjector{
	Write-Output "[Flash Player Projector] Downloading flash player projector..."
	
	Invoke-WebRequest $FPProjectorURL -OutFile .\flashplayer_32_sa.exe
}

function Script:Build-Converter{
	# Step 0: Utilities
	Utility-JavaJDKPrepare
	Utility-GitPortablePrepare
	Utility-Python3Prepare
	
	# Step 1: Create work directory
	Write-Output "[Converter] Creating working directory..."
	New-Item -Path . -Name "work" -ItemType "directory" | Out-Null
	
	# Step 2: Copy converter to work directory
	Write-Output "[Converter] Copying converter source to work directory"
	Copy-Item -Recurse -Path .\Resources\Converter -Destination .\work | Out-Null
	
	# Step 3: Clone Sharp
	Write-Output "[Converter] Cloning Sharp from GitHub..."
	git.exe clone https://github.com/SharpScratchMod/Sharp.git --depth=1 .\work\Sharp
	
	# Step 4: Copy Gradle to converter
	Write-Output "[Converter] Copying Sharp's Gradle wrapper to Converter..."
	Copy-Item -Recurse -Path .\work\Sharp\gradle -Destination .\work\Converter | Out-Null
	New-Item -Path .\work\Converter -Name "libs" -ItemType "directory" | Out-Null
	Copy-Item -Path .\work\Sharp\libs\as3corelib.swc -Destination .\work\Converter\libs | Out-Null
	Copy-Item -Path .\work\Sharp\gradlew -Destination .\work\Converter | Out-Null
	Copy-Item -Path .\work\Sharp\gradlew.bat -Destination .\work\Converter | Out-Null
	
	# Step 5: Copy loader to Sharp src directory
	Write-Output "[Converter] Copying loader to Sharp's source directory"
	Copy-Item -Recurse -Path .\Resources\Loader -Destination .\work\Sharp\src | Out-Null
	Copy-Item -Path .\Resources\Project.sharp -Destination .\work\Sharp\src\Loader | Out-Null
	Copy-Item -Path .\Resources\Settings.txt -Destination .\work\Sharp\src\Loader | Out-Null
	
	# Step 6: Modify Sharp's scratch.gradle, build.gradle, config.groovy, Scratch.as (disable the welcome msg line)
	Write-Output "[Converter] Tweaking Sharp files to use loader..."
	Copy-Item -Path .\Resources\scratch.gradle -Destination .\work\Sharp | Out-Null
	Copy-Item -Path .\Resources\build.gradle -Destination .\work\Sharp | Out-Null
	Copy-Item -Path .\Resources\config.groovy -Destination .\work\Sharp | Out-Null
	
	$WelcomeMsgLocation = (Get-Content .\work\Sharp\src\Scratch.as | Out-String).Replace("if(isOffline) DialogBox.notify", "//")
	[System.IO.File]::WriteAllText((Resolve-Path .\work\Sharp\src\Scratch.as), $WelcomeMsgLocation)
	
	# Step 7: Compile Sharp
	Push-Location .\work\Sharp | Out-Null
	Write-Output "[Converter] Building Sharp... This might take a while..."
	Start-Process -FilePath .\gradlew.bat -WorkingDirectory . -NoNewWindow -Wait -ArgumentList "build -Ptarget=11.6swf"
	Pop-Location | Out-Null
	
	# Step 8: Run Python script to get the .bin files
	Write-Output "[Converter] Cutting up SharpSWF.swf to get some important parts..."
	Push-Location .\work | Out-Null
	Start-Process -FilePath python.exe -WorkingDirectory . -NoNewWindow -Wait -ArgumentList '..\Resources\partgen.py --sb2 ".\Sharp\src\Loader\Project.sharp" --settings ".\Sharp\src\Loader\Settings.txt" ".\Sharp\build\11.6swf\SharpSWF.swf"'
	Pop-Location
	
	# Step 9: Move bin files into the converter's src directory
	Write-Output "[Converter] Moving important parts of SharpSWF.swf to converter source directory..."
	Move-Item -Path .\work\PartChunkAfter.bin -Destination .\work\Converter\src | Out-Null
	Move-Item -Path .\work\PartChunkBefore.bin -Destination .\work\Converter\src | Out-Null
	Move-Item -Path .\work\PartChunkBetween.bin -Destination .\work\Converter\src | Out-Null
	Move-Item -Path .\work\PartHeader.bin -Destination .\work\Converter\src | Out-Null
	Move-Item -Path .\work\PartSB2Header.bin -Destination .\work\Converter\src | Out-Null
	Move-Item -Path .\work\Order.bin -Destination .\work\Converter\src | Out-Null
	
	# Step 10: Compile Converter
	Write-Output "[Converter] Building converter..."
	Push-Location .\work\Converter | Out-Null
	Start-Process -FilePath .\gradlew.bat -WorkingDirectory . -NoNewWindow -Wait -ArgumentList "build"
	Pop-Location | Out-Null
	
	# Step 11: Move converter to output directory
	Write-Output "[Converter] Moving converter to Converter.swf"
	Move-Item -Path .\work\Converter\build\Converter.swf -Destination .
	
	# Step 12: Remove work directory
	Write-Output "[Converter] Removing work directory..."
	Remove-Item -Recurse -Force .\work
	
	# Step 13: Create projector for Converter.swf
	if(Test-Path -Path .\flashplayer_32_sa.exe){
		Write-Output "[Converter] Creating Converter.exe for quick access..."
		$FP32SA = [System.IO.File]::ReadAllBytes((Resolve-Path ".\flashplayer_32_sa.exe"))
		$FP32SAlist = New-Object -TypeName System.Collections.Generic.List[byte]
		$FP32SAlist.AddRange($FP32SA)
		
		$ConverterSWF = [System.IO.File]::ReadAllBytes((Resolve-Path ".\Converter.swf"))
		$FP32SAList.AddRange($ConverterSWF)
		
		$FP32SAList.Add(0x56)
		$FP32SAList.Add(0x34)
		$FP32SAList.Add(0x12)
		$FP32SAList.Add(0xFA)
		
		$SizeBytes = [System.BitConverter]::GetBytes($ConverterSWF.Length)
		if([System.BitConverter]::IsLittleEndian){
			$FP32SAList.AddRange($SizeBytes)
		}
		
		[System.IO.File]::WriteAllBytes((Resolve-Path ".").Path + "\Converter.exe", $FP32SAList.ToArray())
	}
}

function Script:Build-Projector{
	# Step 0: Utilities
	Utility-JavaJDKPrepare
	Utility-GitPortablePrepare

	# Step 1: Create work directory
	Write-Output "[Projector] Creating work directory..."
	New-Item -Path . -Name "work" -ItemType "directory" | Out-Null
	
	# Step 2: Copy Projector to Work Directory
	Write-Output "[Projector] Copying projector to work directory..."
	Copy-Item -Recurse -Path .\Resources\Projector -Destination .\work | Out-Null
	
	# Step 3: Clone Sharp
	Write-Output "[Projector] Cloning Sharp for gradle..."
	git.exe clone https://github.com/SharpScratchMod/Sharp.git --depth=1 .\work\Sharp
	
	# Step 4: Copy the gradle, gradlew, gradlew.bat and libs/as3corelib.swc files
	Write-Output "[Projector] Copying gradle, gradlew, gradlew.bat and libs/as3corelib.swc to projector"
	New-Item -Path .\work\Projector -Name "libs" -ItemType "directory" | Out-Null
	Copy-Item -Recurse -Path .\work\Sharp\gradle -Destination .\work\Projector | Out-Null
	Copy-Item -Path .\work\Sharp\gradlew -Destination .\work\Projector | Out-Null
	Copy-Item -Path .\work\Sharp\gradlew.bat -Destination .\work\Projector | Out-Null
	Copy-Item -Path .\work\Sharp\libs\as3corelib.swc -Destination .\work\Projector\libs | Out-Null
	
	# Step 5: Build Projector
	Write-Output "[Projector] Building projector..."
	Push-Location .\work\Projector | Out-Null
	cmd.exe /c "gradlew.bat build"
	Pop-Location | Out-Null
	
	# Step 6: Copy Projector to output directory
	Write-Output "[Projector] Copying projector to output directory..."
	Move-Item -Path .\work\Projector\build\Projector.swf -Destination . | Out-Null
	
	# Step 7: Remove work directory
	Write-Output "[Projector] Removing work directory..."
	Remove-Item -Recurse -Force -Path .\work
	
	# Step 8: Create projector for Projector.swf
	if(Test-Path -Path .\flashplayer_32_sa.exe){
		Write-Output "[Projector] Creating Projector.exe for quick access..."
		$FP32SA = [System.IO.File]::ReadAllBytes((Resolve-Path ".\flashplayer_32_sa.exe"))
		$FP32SAlist = New-Object -TypeName System.Collections.Generic.List[byte]
		$FP32SAlist.AddRange($FP32SA)
		
		$ProjectorSWF = [System.IO.File]::ReadAllBytes((Resolve-Path ".\Projector.swf"))
		$FP32SAList.AddRange($ProjectorSWF)
		
		$FP32SAList.Add(0x56)
		$FP32SAList.Add(0x34)
		$FP32SAList.Add(0x12)
		$FP32SAList.Add(0xFA)
		
		$SizeBytes = [System.BitConverter]::GetBytes($ProjectorSWF.Length)
		if([System.BitConverter]::IsLittleEndian){
			$FP32SAList.AddRange($SizeBytes)
		}
		
		[System.IO.File]::WriteAllBytes((Resolve-Path ".").Path + "\Projector.exe", $FP32SAList.ToArray())
	}
}

function Script:Menu1{
	if(-Not (Test-Path -Path .\flashplayer_32_sa.exe)){
		Write-Output ""
		Write-Output "Warning"
		Write-Output "==========="
		Write-Output "You do not have a copy of Flash Player projector in this folder (with name 'flashplayer_32_sa.exe')."
		Write-Output ""
		Write-Output "[1] Download Flash Player Projector"
		Write-Output "[2] Open Flash Player Projector download site"
		Write-Output "[3] Continue without Flash Player projector (this means that Compiler and Projector will only be provided as SWF files"
		Write-Output ""
		$O = Read-Host
		if($O -eq "1"){
			Utility-FlashProjector
			Menu2
		}elseif($O -eq "2"){
			cmd.exe /c "start https://www.adobe.com/support/flashplayer/debug_downloads.html"
			Write-Output "!! Don't forget to place the file in the same folder as Build.ps1 with the original name flashplayer_32_sa.exe !!"
			Write-Output "Note: Re-run script when downloaded to continue"
			exit
		}elseif($O -eq "3"){
			Write-Output "!! Skipping flash player projector..."
			Menu2
		}else{
			Write-Output "!! Incorrect Option! Retry! !!"
			Menu1
		}
	}else{
		Menu2
	}
}

function Script:Menu2{
	Write-Output ""
	Write-Output 'Sharp2SWF and Unoffical Junebeetle "Create Projector" Workaround build tool'
	Write-Output ""
	Write-Output "[1] Compile Sharp2SWF (modified 'Scratch 2 to SWF Converter' by Junebeetle"
	Write-Output '[2] Compile "Create Projector" Workaround - for making SWFs into EXEs'
	Write-Output "[3] Compile both"
	Write-Output "[4] Usage"
	Write-Output "[5] Credits"
	Write-Output "[6] Exit"
	Write-Output ""
	$O = Read-Host
	if($O -eq "1"){
		Build-Converter
		Write-Output ""
		Write-Output "===================="
		Write-Output "Complete!"
		Write-Output "===================="
		Write-Output ""
	}elseif($O -eq "2"){
		Build-Projector
		Write-Output ""
		Write-Output "===================="
		Write-Output "Complete!"
		Write-Output "===================="
		Write-Output ""
	}elseif($O -eq "3"){
		Build-Converter
		Build-Projector
		Write-Output ""
		Write-Output "===================="
		Write-Output "Complete!"
		Write-Output "===================="
		Write-Output ""
	}elseif($O -eq "4"){
		MenuUsage
	}elseif($O -eq "5"){
		MenuCredits
	}elseif($O -eq "6"){
		exit
	}else{
		Menu2
	}
}

function Script:MenuCredits{
	Write-Output ""
	Write-Output "Sharp2SWF is based off Junebeetle's Scratch 2 to SWF Converter."
	Write-Output "The Converter part is unmodified except for using Gradle to build."
	Write-Output "The Loader part is mostly unmodified except that it looks for Project.sharp instead of Project.sb2."
	Write-Output "The build script is recreated in Python and PowerShell."
	Write-Output "Scratch, Sharp and Junebeetle's Scratch 2 to SWF Converter are under GPL v2 license."
	Write-Output ""
	Write-Output "Projector is a mostly unmodified version of Junebeetle's Create Projector Workaround."
	Write-Output "The only modification is to remove a line of code that was unneeded and caused the build to fail."
	Write-Output "Other than that, this mainly just serves as a easy build utility."
	Write-Output ""
	Write-Output "Press enter to return to menu"
	Read-Host
	Menu2
}

function Script:MenuUsage{
	Write-Output ""
	Write-Output "1. In the menu, select 'Compile Both' (option 3)."
	Write-Output "2. Once complete, open Converter.exe."
	Write-Output "3. Select your Scratch file."
	Write-Output "4. Select where and what you want to call your SWF file."
	Write-Output "5. Open Projector.exe."
	Write-Output "6. Select flashplayer_32_sa.exe."
	Write-Output "7. Select your project's SWF file."
	Write-Output "8. Select where and what you want to call your EXE file."
	Write-Output ""
	Write-Output "For more detailed instructions, see README.md"
	Write-Output ""
	Write-Output "Press enter to return to menu"
	Write-Output ""
	Read-Host
	Menu2
}

Menu1

$env:PATH = $OrigPath