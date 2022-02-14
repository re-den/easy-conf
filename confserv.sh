#!/bin/bash
ver="v0.0.211                  "
title="Easy Install Shell"
title_full="$title $ver"
#-----------------
#типовые функции
#-----------------

filename="confserv.sh"
updpath="https://github.com/re-den/easy-conf.git"

title()
{
my_clear
echo "$title"
}

menu()
{
my_clear
echo "$menu"
echo "Выберите пункт меню:"
}

wait()
{
echo "Нажмите любую клавишу, чтобы продолжить..."
read -s -n 1
}

br()
{
echo ""
}

updatescript()
{
wget $updpath/$filename -r -N -nd --no-check-certificate
chmod 777 $filename
}

my_clear()
{
echo -e "$textcolor$bgcolor"
clear
}

#функция, которая запрашивает только один символ
myread()
{
temp=""
while [ -z "$temp" ] #защита от пустых значений
do
read -n 1 temp
done
eval $1=$temp
echo
}

#функция, которая запрашивает только да или нет
myread_yn()
{
temp=""
while [[ "$temp" != "y" && "$temp" != "Y" && "$temp" != "n" && "$temp" != "N" ]] #запрашиваем значение, пока не будет "y" или "n"
do
echo -n "y/n: "
read -n 1 temp
echo
done
eval $1=$temp
}

#функция, которая запрашивает только цифру
myread_dig()
{
temp=""
counter=0
while [[ "$temp" != "0" && "$temp" != "1" && "$temp" != "2" && "$temp" != "3" && "$temp" != "4" && "$temp" != "5" && "$temp" != "6" && "$temp" != "7" && "$temp" != "8" && "$temp" != "9" ]] #запрашиваем значение, пока не будет цифра
do
if [ $counter -ne 0 ]; then echo -n "Неправильный выбор. Ведите цифру: "; fi
let "counter=$counter+1"
read -n 1 temp
echo
done
eval $1=$temp
}

mc_install()
{
#update source list
apt update
#Install mc
pr_inst=`dpkg -s mc | grep ok | awk '{print $3}'` #Проверка установлен MC или нет
if [ "$pr_inst" -eq "ok" ]; then
echo "Midnight Commander уже установлен"
else
echo "Начинаю установку"
apt -y install mc
samba_conf
fi
}

webmin_install()
{
# add repository for WebMin
echo "### ---------- WebMin.source-----------" >> /etc/apt/sources.list
echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
echo "### ---------- end WebMin.source-----------" >> /etc/apt/sources.list
# add PGP-key Webmin
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
#update source list
apt-get update
#Install Webmin
apt-get -y install webmin
}

samba_conf()
{
#echo "Укажите название общей папки"
#read share
echo "Укажите локальный каталог, который нужно сделать общим"
read loc_dir
#echo $HOME/$loc_dir
echo "Samba уже установлена. Начинаем настройку.\n"
echo "Укажите локальный каталог, который нужно сделать общим. Если его нет, то он будет создан."
read loc_dir
mkdir $HOME/$loc_dir
chmod 777 $HOME/$loc_dir
echo "Начинаем настройку Samba."
{
echo "[$loc_dir]"
echo "writable = yes"
echo "path = $HOME/$loc_dir"
echo "public = yes" 
} >> /etc/samba/smb.conf
service smbd restart	
}

menu="
┌─────────────────────────────────────────────┐
│  $title $ver$space│
├───┬─────────────────────────────────────────┤
│ 1 │ Установка WebMin                        │
├───┼─────────────────────────────────────────┤
│ 2 │ Установить Midnight Commander (MC)      │
├───┼─────────────────────────────────────────┤
│ 3 │ Удалить %packet% полностью              │
├───┼─────────────────────────────────────────┤
│ 4 │ Установка и настройка Samba             │
├───┼─────────────────────────────────────────┤
│ 5 │                                         │
├───┼─────────────────────────────────────────┤
│ 6 │                                         │
├───┼─────────────────────────────────────────┤
│ 7 │                                         │
├───┼─────────────────────────────────────────┤
│ 8 │                                         │
├───┼─────────────────────────────────────────┤
│ 9 │ Обновить Easy ConfServ с GitHub         │
├───┼─────────────────────────────────────────┤
│ 0 │ Выход                                   │
└───┴─────────────────────────────────────────┘
"

#-----------------
#Интерфейс
#-----------------
repeat=true
chosen=0
chosen2=0
while [ "$repeat" = "true" ] #выводим меню, пока не надо выйти
do

#пошёл вывод
if [ $chosen -eq 0 ]; then #выводим меню, только если ещё никуда не заходили
echo "$title"
echo "$menu"
myread_dig pick
else
pick=$chosen
fi

case "$pick" in
1) #Webmin install
	my_clear
	echo "Запускаю установку Webmin"
	webmin_install
	my_clear
	br
	wait
	;;
2) #Показать общую информацию о системе
	my_clear
	echo "Запускаю установку MC"
	mc_install
	my_clear
	br
	wait
	;;
3) #Удалить какую-либо программу со всеми зависимостями
        echo "Укажите название пакета который нужно полностью удалить"
        read answer
        apt-get purge $answer
        br
        echo "Готово."
        wait
	;;
4) #Установка Samba
	pr_inst=`dpkg -s samba | grep ok | awk '{print $3}'`
	if [ "$pr_inst" -eq "ok" ]; then
	samba_conf
	else
	echo "Необходимо установить Samba"
	apt install -y samba
	samba_conf
	fi
	;;
9) #Обновить Easy ConfServ
	echo "обновляю..."
	updatescript
	repeat=true
	wait
	sh $0
	exit 0
	;;
0) repeat=false
	;;
	*)
	echo "Неправильный выбор. $pick"
	wait
	;;
esac
done
echo "Скрипт ожидаемо завершил свою работу."
echo -e "$normal"
clear
