#!/usr/bin/bash

###########################################
### GLOBAL variables
pdSourceCode_GLOBAL= # global variable with Pd source code filename
pdWin32Bin_GLOBAL= # global variable with Pd Win32 binary filename
pdWin64Bin_GLOBAL= # global variable with Pd Win64 binary filename
externalSourceCode_GLOBAL= # global variable with external source code filename

scriptPATH="$PWD" # script folder address
sourcesPATH="$scriptPATH/sources" # pd and external source code files folder
externalBinariesPATH="$scriptPATH/externalBinaries" # folder wich external binaries will be created
compilationFolder="$scriptPATH/pdExternalCompilation"  # temporary folder where compilation happen


#################################################
### setting filenames and paths GLOBAL variables

setGlobal_fileNames() ### parse filename and atributte to global fileName
{
	local filename=$1

	case $filename in
		*-i386.msw.zip)
		 pdWin32Bin_GLOBAL=$filename
		 ;;

		*.msw.zip)
		 pdWin64Bin_GLOBAL=$filename
		 ;;

		*.src.tar.gz)
		 pdSourceCode_GLOBAL=$filename
		 ;;

		*.zip)
		 externalSourceCode_GLOBAL=$filename
		 ;;
	esac
}

set_fileNames()
{
	cd "$sourcesPATH"
	shopt -s nullglob
	local files=("pd-"*) ### create local array with files with prefix "pd-"
	  for (( i=0; i<${#files[@]}; i++ )) do
	  setGlobal_fileNames ${files[$i]}
	done
	cd ..
}


#############################################
## coping external's source to script folder
prepare_sources()
{
	rm -fr "$compilationFolder"
	mkdir "$compilationFolder" && mkdir "$compilationFolder/pd-win"
	cp "$sourcesPATH/$externalSourceCode_GLOBAL" "$compilationFolder"
	tar -xf "$sourcesPATH/$pdSourceCode_GLOBAL" -C "$compilationFolder"
	unzip "$sourcesPATH/$pdWin32Bin_GLOBAL" -d "$compilationFolder/pd-win/"
	unzip "$sourcesPATH/$pdWin64Bin_GLOBAL" -d "$compilationFolder/pd-win/"
}
	

#############################################
## init script
## - find for sources
## - create compilation environment
##    - create tmp folder
##    - copy external source code to tmp folder
##    - extract pd source files to tmp folder

init()
{
	mkdir "$compilationFolder"
	set_fileNames #set GLOBAL variables
	prepare_sources #create compilation environment
}


#####################################
## cut "pd-" prefix from filename
cut_pd_prefix()
{
  local fileName=$1
  local n=${#fileName}
  fileName=$(echo $fileName | cut -c4-$n)

  echo $fileName
}


########################################
## cut extension from name or filename (melhorar esta inteligencia)
cut_extension()
{
  local filename=$1

  case $filename in
  $pdWin32Bin_GLOBAL)
    local temp=$(basename $filename .msw.zip)
    echo $temp
    ;;

  $pdWin64Bin_GLOBAL)
    local temp=$(basename $filename .msw.zip)
    echo $temp
    ;;

  $pdSourceCode_GLOBAL)
    local temp=$(basename $filename .src.tar.gz)
    echo $temp
    ;;

  $externalSourceCode_GLOBAL)
    local temp=$(basename $filename .zip)
    echo $temp
    ;;
  esac
}


##################################################################
## setting external name (melhorar pesquisando no pd-lib-builder)
set_externalName()
{
  local externalSourceCodeFileName=$1
  local name=$(cut_pd_prefix $externalSourceCodeFileName)
  local beginName=$(echo $name | cut -c1-4);

  if [ "$beginName" == "cycl" ]
  then
  	name="cyclone"
  elif [ "$beginName" == "else" ]
  then
  	name="else"
  else
  	echo "set_externalName(): Fail to identify external name"
  	return 1
  fi
  
  echo $name
}


########################################################
## Echo unziped external folder name. 
set_externalFolderName()
{
	local externalFolder=$1

	externalFolder=$(cut_extension "$externalFolder")
	#externalFolder=$(cut_pd_prefix "$externalFolder")

	echo $externalFolder
}


##################################
### Echo pd Source name version
set_pdSourceName()
{
	local pdSourceName=$1

	pdSourceName=$(cut_extension $pdSourceName)

	echo $pdSourceName
}

	
#########################################################################
###                 COMPILING EXTERNAL FOR ALL ARCHs                  ###
#########################################################################

#####################################
## Preparing Pd external compilation
begining_compile()
{
	source /etc/environment && LD_LIBRARY_PATH=""

	cd "$compilationFolder"
	unzip $externalSourceCode
	cd "$externalFolder"
}


######################################
## Finalizing Pd external compilation
ending_compile()
{
	local finalZipName="$(cut_pd_prefix "$nameBinaryZIP")"

	#linha que adiciona Tutorial
	mv "$compilationFolder/$externalFolder/Live-Electronics-Tutorial" "$compilationFolder/$externalFolderARCH/$name/Live-Electronics-Tutorial"

	cd ..
	rm -fr "$externalFolder"
	cd "$externalFolderARCH"

	#código que renomeia extensão dos externals por arquitetura
	cd $name
	for file in *.pd_linux
	do
		mv -v "$file" "${file%.pd_linux}.$extension"
	done;
	for file in *.dll
	do
		mv -v "$file" "${file%.dll}.$extension"
	done;
	cd ..
	#fim do código de renomeação

	zip -r $nameBinaryZIP $name/
	mv $nameBinaryZIP "$externalBinariesFolder/$finalZipName"
	cd ..
	rm -fr "$externalFolderARCH"

	source /etc/environment && LD_LIBRARY_PATH=""
}

##############
## Linux 32 ##
##############
compile_Linux32()
{
	local name="$1"
	local externalFolder="$2"
	local externalSourceCode="$3"
	local pdSourceName="$4"
	local compilationFolder="$5"
	local externalBinariesFolder="$6"
	local nameBinaryZIP="$externalFolder"_Linux32.zip
	local externalFolderARCH="$externalFolder"_Linux32
	local extension="l_i386"

	begining_compile

	make CC='gcc -m32' target.arch=i*86 pdincludepath=../$pdSourceName/src && make install objectsdir=../$externalFolderARCH #extension=l_i386

	ending_compile
}


##############
## Linux 64 ##
##############
compile_Linux64()
{
	local name="$1"
	local externalFolder="$2"
	local externalSourceCode="$3"
	local pdSourceName="$4"
	local compilationFolder="$5"
	local externalBinariesFolder="$6"
	local nameBinaryZIP="$externalFolder"_Linux64.zip
	local externalFolderARCH="$externalFolder"_Linux64
	local extension="l_amd64"

	begining_compile

	make pdincludepath=../$pdSourceName/src && make install objectsdir=../$externalFolderARCH extension=l_amd64

	ending_compile
}

##########################
## Raspberry - armv6-32 ##
##########################
compile_armv6()
{
	local name="$1"
	local externalFolder="$2"
	local externalSourceCode="$3"
	local pdSourceName="$4"
	local compilationFolder="$5"
	local externalBinariesFolder="$6"
	local nameBinaryZIP="$externalFolder"_armv6_Linux32.zip
	local externalFolderARCH="$externalFolder"_armv6_Linux32
	local extension="l_arm"

	begining_compile
	PATH=~/rpiCrossCompilerToolchains/buster/cross-pi-gcc-8.3.0-0/bin:$PATH && LD_LIBRARY_PATH=~/rpiCrossCompilerToolchains/buster/cross-pi-gcc-8.3.0-0/lib:$LD_LIBRARY_PATH 

	make CC=arm-linux-gnueabihf-gcc target.arch=armv6 pdincludepath=../$pdSourceName/src install objectsdir=../$externalFolderARCH extension=pd_linux

	ending_compile
}

##########################
## Raspberry - armv7-32 ##
##########################
compile_armv7()
{
	local name="$1"
	local externalFolder="$2"
	local externalSourceCode="$3"
	local pdSourceName="$4"
	local compilationFolder="$5"
	local externalBinariesFolder="$6"
	local nameBinaryZIP="$externalFolder"_armv7_Linux32.zip
	local externalFolderARCH="$externalFolder"_armv7_Linux32
	local extension="l_arm"

	begining_compile
	PATH=~/rpiCrossCompilerToolchains/buster/cross-pi-gcc-8.3.0-1/bin:$PATH && LD_LIBRARY_PATH=~/rpiCrossCompilerToolchains/buster/cross-pi-gcc-8.3.0-1/lib:$LD_LIBRARY_PATH

	make CC=arm-linux-gnueabihf-gcc target.arch=arm7l pdincludepath=../$pdSourceName/src install objectsdir=../$externalFolderARCH extension=l_arm

	ending_compile
}


##########################
## Raspberry - armv8-64 ##
##########################
compile_armv8()
{
	local name="$1"
	local externalFolder="$2"
	local externalSourceCode="$3"
	local pdSourceName="$4"
	local compilationFolder="$5"
	local externalBinariesFolder="$6"
	local nameBinaryZIP="$externalFolder"_armv8_Linux64.zip
	local externalFolderARCH="$externalFolder"_armv8_Linux64
	local extension="l_arm64"
	
	begining_compile
	PATH=~/rpiCrossCompilerToolchains/buster/cross-pi-gcc-8.3.0-64/bin:$PATH && LD_LIBRARY_PATH=~/rpiCrossCompilerToolchains/buster/cross-pi-gcc-8.3.0-64/lib:$LD_LIBRARY_PATH

	make CC=aarch64-linux-gnu-gcc target.arch=arm8-a pdincludepath=../$pdSourceName/src install objectsdir=../$externalFolderARCH extension=l_arm64

	ending_compile
}


#######################
## Windows - 32 bits ##
#######################
compile_win32()
{
	local name="$1"
	local externalFolder="$2"
	local externalSourceCode="$3"
	local pdSourceName="$4"
	local compilationFolder="$5"
	local externalBinariesFolder="$6"
	local nameBinaryZIP="$externalFolder"_Win32.zip
	local externalFolderARCH="$externalFolder"_Win32
	local extension="m_i386"

	
	begining_compile

	make PLATFORM=i686-w64-mingw32 PDDIR=../pd-win/$pdSourceName install objectsdir=../$externalFolderARCH extension=dll

	ending_compile
}



#######################
## Windows - 64 bits ##
#######################
compile_win64()
{
	local name="$1"
	local externalFolder="$2"
	local externalSourceCode="$3"
	local pdSourceName="$4"
	local compilationFolder="$5"
	local externalBinariesFolder="$6"
	local nameBinaryZIP="$externalFolder"_Win64.zip
	local externalFolderARCH="$externalFolder"_Win64
	local extension="m_amd64"

	
	begining_compile

	make PLATFORM=x86_64-w64-mingw32 PDDIR=../pd-win/$pdSourceName install objectsdir=../$externalFolderARCH extension=m_amd64

	ending_compile
}




###End of compilation
end()
{
	source /etc/environment && LD_LIBRARY_PATH=""
	rm -fr "$compilationFolder"

	echo $"---------------------------------------------------------"
	echo $"  	  ###############################"
	echo $"   		COMPILATION IS OVER"
	echo $" 	  ###############################"
	echo
	echo $"           see the folder: externalBinaries"
	echo
	echo $"---------------------------------------------------------"
}


########################
##    Compile ALL     ##
########################
compile_ALL()
{
	init

	local name=$(set_externalName $externalSourceCode_GLOBAL)
	local externalFolder=$(set_externalFolderName $externalSourceCode_GLOBAL)
	local pdSourceName=$(set_pdSourceName $pdSourceCode_GLOBAL)
	local pdWin32Name=$(set_pdSourceName $pdWin32Bin_GLOBAL)
	local pdWin64Name=$(set_pdSourceName $pdWin64Bin_GLOBAL)
	
	compile_Linux32 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"	
	compile_Linux64 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"
	compile_armv6 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"
	compile_armv7 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"
	compile_armv8 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"
	compile_win32 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdWin32Name" "$compilationFolder" "$externalBinariesPATH"
	compile_win64 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdWin64Name" "$compilationFolder" "$externalBinariesPATH"
	
	end
}



########################
##    For testing     ##
########################
test()
{
	init
	#set_fileNames

	local name=$(set_externalName $externalSourceCode_GLOBAL)
	local externalFolder=$(set_externalFolderName $externalSourceCode_GLOBAL)
	local pdSourceName=$(set_pdSourceName $pdSourceCode_GLOBAL)
	local pdWin32Name=$(set_pdSourceName $pdWin32Bin_GLOBAL)
	local pdWin64Name=$(set_pdSourceName $pdWin64Bin_GLOBAL)

	#compile_Linux32 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"	
	compile_Linux64 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"
	#compile_armv6 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"
	#compile_armv7 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"
	#compile_armv8 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdSourceName" "$compilationFolder" "$externalBinariesPATH"
	#compile_win32 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdWin32Name" "$compilationFolder" "$externalBinariesPATH"
	#compile_win64 $name "$externalFolder" "$externalSourceCode_GLOBAL" "$pdWin64Name" "$compilationFolder" "$externalBinariesPATH"
	
	end
}


###################
###    RUN...   ###
###################

compile_ALL
#test

