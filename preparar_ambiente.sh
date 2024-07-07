#!/usr/bin/bash

#######################################################################################
## Script de preparação do ubuntu 18.04 para cross compile de externals else e cyclone

scriptPATH="$PWD" # script folder address - global variable


################################
## Preparar estrutura de pastas
create_folders()
{
	mkdir "$scriptPATH/sources" && mkdir "$scriptPATH/externalBinaries"	#cria estrutura de pastas
	mkdir ~/rpiCrossCompilerToolchains && mkdir ~/rpiCrossCompilerToolchains/buster

	return 0
}


#########################
## Install deken
install_deken()
{
	mkdir -p ~/bin/
	export PATH="$PATH:~/bin"
	source ~/.profile
	curl https://raw.githubusercontent.com/pure-data/deken/master/developer/deken > ~/bin/deken
	chmod 755 ~/bin/deken
	deken
}


#########################
## Instalar dependencias

install_dependencies()
{
	sudo apt update && sudo apt -y dist-upgrade

	sudo apt-get -y install build-essential curl gawk gcc g++ gfortran git python3-distutils texinfo bison libncurses-dev lynx gcc-8 mingw-w64 gcc-8-multilib gcc-8-multilib-i686-linux-gnu linux-libc-dev:i386

	install_deken

	cd ~/rpiCrossCompilerToolchains/buster

	wget https://ufpr.dl.sourceforge.net/project/raspberry-pi-cross-compilers/Raspberry%20Pi%20GCC%20Cross-Compiler%20Toolchains/Buster/GCC%208.3.0/Raspberry%20Pi%201%2C%20Zero/cross-gcc-8.3.0-pi_0-1.tar.gz

	wget https://ufpr.dl.sourceforge.net/project/raspberry-pi-cross-compilers/Raspberry%20Pi%20GCC%20Cross-Compiler%20Toolchains/Buster/GCC%208.3.0/Raspberry%20Pi%202%2C%203/cross-gcc-8.3.0-pi_2-3.tar.gz

	wget https://ufpr.dl.sourceforge.net/project/raspberry-pi-cross-compilers/Raspberry%20Pi%20GCC%20Cross-Compiler%20Toolchains/Buster/GCC%208.3.0/Raspberry%20Pi%203A%2B%2C%203B%2B%2C%204/cross-gcc-8.3.0-pi_3%2B.tar.gz

	wget https://master.dl.sourceforge.net/project/raspberry-pi-cross-compilers/Bonus%20Raspberry%20Pi%20GCC%2064-Bit%20Toolchains/Raspberry%20Pi%20GCC%2064-Bit%20Cross-Compiler%20Toolchains/GCC%208.3.0/cross-gcc-8.3.0-pi_64.tar.gz

	tar -xvf cross-gcc-8.3.0-pi_0-1.tar.gz && tar -xvf cross-gcc-8.3.0-pi_2-3.tar.gz && tar -xvf cross-gcc-8.3.0-pi_3+.tar.gz && tar -xvf cross-gcc-8.3.0-pi_64.tar.gz

	return 0
}


############################################
## baixar código fonte e binários win do Pd

download_pdBinaries()
{
	cd "$scriptPATH/sources"

	wget http://msp.ucsd.edu/Software/pd-0.51-2.src.tar.gz
	wget http://msp.ucsd.edu/Software/pd-0.51-2-i386.msw.zip
	wget http://msp.ucsd.edu/Software/pd-0.51-2.msw.zip

	cd ..

	return 0
}

#################################
## movendo scripts de compilação
install_scripts()
{

	# baixar scripts do github


	# criar arquivo com instruções e apagar este script do diretório atual

	return 0
}



###Fim da compilacao
end()
{
	echo $"----------------------------------------------------------"
	echo $"  	  ###############################"
	echo $"      		 Está tudo pronto!"
	echo $" 	  ###############################"
	echo $"    na pasta onde vc colocou este script abra o Terminal"
	echo
	echo
	echo $"	 Para compilar copie o código fonte da biblioteca de "
	echo $"	 externals para a pasta: sources"
	echo
	echo $"	 O código fonte e binários Win do Pd já foram baixados"
	echo $"  na versão 0.51-2, para outras versões baixar manualmente"
	echo $"  e substituir."
	echo
	echo $"  para compilar, na pasta onde está o script,"
	echo $"  no terminal digite:"
	echo
	echo $"    bash vai.sh "
	echo
	echo
	echo $"	 a compilação será iniciada e os binários gerados serão"
	echo $"	 copiados para a pasta: externalBinaries"
	echo
	echo
	echo $"  Para compilar outra versão do external, apague a versão"
	echo $"  anterior e copie a nova versão para a pasta: sources"
	echo
	echo $"----------------------------------------------------------"

	return 0
}


## PROGRAMA PRINCIPAL
main()
{
    install_dependencies
    create_folders
    download_pdBinaries
    #install_scripts
	#install_deken
    end

    return 0
}

#RUN
main

