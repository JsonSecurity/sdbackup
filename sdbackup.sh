#!/bin/bash

#===================dir backup======================
dir_file="/data/data/com.termux/files/home/sdbackup/file/"
dir_backup="/data/data/com.termux/files/home/sdbackup/backup/"
#===================================================

#colores
R="\e[31m"
G="\e[32;1m"
Y="\e[33;1m"
B="\e[34m"
P="\e[31;1m"
C="\e[1;34m"
W="\e[0m"
L="\e[10;1m"
N="\e[30;1m"
#true
T="$N [${R}+${N}]$W"
T1="$L [${G}+${L}]$W"
T2="$N [${Y}+${N}]$W"
#false
F="$G [${W}-${G}]$W"
F1="$L [${R}-${L}]$W"
F2="$B [${R}-${B}]$W"
#err
alert="$N [${R}!${N}]$W"
#mas
Wa="$B [${R}...${B}]$W"
Ch="$N [${G}✓${N}]$W"
Qu="$N [${Y}?${N}]$W"
Fail="$N [${R}✘${N}]$W"
A="$R •${G}❯${N}❯$W"

YN="$N[${W}Y${N}/${W}N${N}]:$W"

temp_file=$dir_file
temp_back=$dir_backup

logo() {
	echo -e """$N
 █${Y}||||||${N}█
 ████████
  ███████	$N [${Y}ᴊsᴏɴ sᴇᴄᴜʀɪᴛʏ${N}]
 ████████ 	$N [${Y}sᴅʙᴀᴄᴋᴜᴘ${N}]
 ███${W}sᴅ${N}███
 ████████

			"""
}
dirbackup() {
	if [[ ! -d $dir_file ]] || [[ ! -d $dir_backup ]]; then
	    echo -e "$alert Carpeta no encontrada\n"
	    exit 1
	else
	    echo -e "\n$Ch FILE:$G $dir_file"
	    echo -e "$Ch BACKUP:$G $dir_backup\n"
	fi
}
listar() {
	echo -e "storage\ndownloads" > .except		
	#archivos=$(ls -hl -p "$dir_file" | awk '{print $5,$9}' | tr ' ' '~' | sed '1d')
	archivos=$(du -sh ${dir_file}* 2>/dev/null | sed 's!'"$dir_file"'!!' | tr '\t' '~')
	
	if [[ ! -n $archivos ]];then
		echo -e "\n$alert No tienes ningun archivo$R $dir_file\n"
		exit 1
	else
		clear
		logo
	fi
	
	cp_dir=$(ls "$dir_file" > .copiar)
	fila=1

	echo -e "$T Archivos encontrados\n"
	for line in $archivos;do		
		echo -e "$N [${Y}$fila${N}]$W $line" | tr '~|/' ' '
		let fila=fila+1
	done
}
change() {
	echo -e "\n$T2 Ingrese el número de un archivo"
	printf "$Qu "
	read numfile

	if [[ -n $numfile ]];then
		file=$(ls "$dir_file" | awk "NR==$numfile")
	fi
}
allexcept() {
	echo -e "\n$T Ingrese archivos a omitir. \"${Y}go${W}\" para iniciar"
	while true;do
		change

		if [[ $numfile -eq 'go' ]];then
			break
		elif [[ ! -z $file ]];then
			echo -e "\n$Fail $file"
			echo $file >> .except
		else
			echo -e "$Fail No encontrado"
		fi
	done
}
listar_backup() {
	clear
	logo
	
	echo -e "$T2 Archivos seleccionados"
	for line in $(cat .copiar);do
		echo -e "$T $line"
		sleep .05
	done
	
	echo -e "\n$T2 Archivos por ingnorar"
	for line in $(cat .except);do
		echo -e "$T $line"
		sleep .05
	done

	dirbackup
}
dir_bk() {
	fecha=$(date | awk '{print $2,$3,$4,$6}' | tr ' ' '-')
	echo -e "$T2 Nombre del backup$N [${G}$fecha${N}] "

	printf  "$Qu "
	read nameback

	nameback="${nameback}-$fecha"
	dir_backup="${dir_backup}$nameback"
	mkdir "$dir_backup"
	echo " "
}
backup() {
	for line in $(cat .copiar);do
		if [[ $(cat .except | grep $line) == $line ]];then
			echo -e "$Fail $line$R ignored"
		else
			cp -rf "${dir_file}$line" "$dir_backup"
			echo -e "$Ch $line$G success"
		fi
	done
	echo ""
}
restore() {
	#intercambio de variables
	temp_file=$dir_file
	temp_back=$dir_backup
	
	dir_file=$dir_backup
	dir_backup=$temp_file
	#---------------------------
	listar
	echo -e "\n$T2 Carpeta a restaurar "
	change
	#---------------------------
	dir_file="$dir_file${file}/"
	dir_backup="$dir_backup"
	#---------------------------
	listar
}
opciones() {
	echo -e "$N [${Y}1${N}]$W all backup"
	echo -e "$N [${Y}2${N}]$W all restore"
	echo -e "$N [${Y}3${N}]$W one backup"
	echo -e "$N [${Y}4${N}]$W one restore"
	#echo -e "$N [${Y}5${N}]$W Unique - Restore"

	printf  "\n$Qu "
	read option

	if [[ $option == 1 ]];then
		listar
		allexcept
		steps
		
	elif [[ $option == 2 ]];then
		restore
		allexcept
		echo -e "\n$T2 Enter para restaurar"
		read enter
		backup
		echo -e "\n$Ch Restaurado en $G$temp_file"
		
	elif [[ $option == 3 ]];then
		listar
		change
		echo $file > .copiar
		steps
		
	elif [[ $option == 4 ]];then	
		restore
		change
		echo $file > .copiar
		steps_restore
	fi
}
start() {
	clear
	logo
	echo '' > .except
	dirbackup
	opciones
}
steps() {
	listar_backup
	dir_bk
	backup
	echo -e "$Ch Guardado en ${G}$dir_backup"
}

steps_restore() {
	arch=$(cat .copiar)
	busq=$(find $temp_file -name $arch)
	
	if [[ -n $(echo $busq) ]];then
		printf  "\n$alert Archivos similares:\n"

		echo -e "\n$T2 $busq"
		echo -e "\n$alert Se reemplaza al archivo de destino"
	fi
	
	echo -e "\n$T2 Enter para restaurar"
	read enter
	backup
	echo -e "\n$Ch Restaurado en $G$temp_file"
}

start
