#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Примечания:
#   В конце каждой команды вы можете увидеть > / dev / null . Это просто подавляет вывод из процессов установки.
#   Если вы хотите увидеть результат при подготовке, просто удалите его.
#   Когда вы пытаетесь установить пакет с помощью команды apt-get install , он всегда запрашивает подтверждение, 
#   флаг -y указывает «да», поэтому он не будет запрашивать подтверждение каждой установки.

sudo apt update > /dev/null
sudo apt -y upgrade > /dev/null
sudo apt autoremove > /dev/null

sudo mkdir -m 777 /usr/src/linux-6.8/ 
sudo wget -q -P /usr/src/linux-6.8/ https://kernel.ubuntu.com/mainline/v6.8/amd64/linux-headers-6.8.0-060800-generic_6.8.0-060800.202403131158_amd64.deb
sudo wget -q -P /usr/src/linux-6.8/ https://kernel.ubuntu.com/mainline/v6.8/amd64/linux-headers-6.8.0-060800_6.8.0-060800.202403131158_all.deb
sudo wget -q -P /usr/src/linux-6.8/ https://kernel.ubuntu.com/mainline/v6.8/amd64/linux-image-unsigned-6.8.0-060800-generic_6.8.0-060800.202403131158_amd64.deb
sudo wget -q -P /usr/src/linux-6.8/ https://kernel.ubuntu.com/mainline/v6.8/amd64/linux-modules-6.8.0-060800-generic_6.8.0-060800.202403131158_amd64.deb

# Перейдём в папку со установочными пакетами
cd /usr/src/linux-6.8/

# Запустим установку
sudo dpkg -i *.deb
# или:
#   sudo dpkg -i linux-headers* linux-image* linux-modules*

# Если команда выше не сработала, можно пойти другим путём:
#   установим утилиту gdebi и с помощью неё устанвоим ядро
#   sudo apt install -y gdebi > /dev/null
#   sudo gdebi linux-headers*.deb linux-image-*.deb linux-modules-*.deb

#   Обновим загрузчик
sudo update-grub

#   Перезагузим систему
sudo shutdown -r now