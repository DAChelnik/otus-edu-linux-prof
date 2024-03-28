# Vagrant-стенд для обновления ядра и создания образа системы

## Цель домашнего задания

* Научиться обновлять ядро в ОС Linux.
* Получить навыки работы с Vagrant.

## Описание домашнего задания

* Запустить ВМ с помощью Vagrant.
* Обновить ядро ОС
* Оформить отчет в README-файле в GitHub-репозитории.

## Рабочее окружение

* Windows 10 22H2 19045.4170
* Git
* Oracle VM VirtualBox 7.0.14 r161095
* Oracle VM VirtualBox Extension Pack
* Vagrant 2.2.7
* Vagrant plugin "vagrant-disksize"
* Vagrant box: almalinux/8 (virtualbox, 8.9.20231219, (amd64))
* Vagrant box: ubuntu/jammy64 (virtualbox, 20240207.0.0)
* Vagrant box: centos/7 (virtualbox, 1905.1)
* GitHub: <https://github.com/DAChelnik/otus-edu-linux-prof>

### Vagrant

Официальная страница: <https://www.vagrantup.com/>  
Репозиторий: <https://github.com/hashicorp/vagrant>  
Бинарные сборки: <https://releases.hashicorp.com/vagrant>  
Зеркало сборок из репозитория: <https://sourceforge.net/projects/vagrant.mirror/files/>  
Репозиторий образов для Vagrant: <https://app.vagrantup.com/>

Зеркало бинарных сборок:

* <https://hashicorp-releases.yandexcloud.net/vagrant/>
* <https://hashicorp-releases.mcs.mail.ru/vagrant/>

## Подготовка стенда

Для развёртывания всех компонент используется Vagrant, с помощью которого разворачивается стенд состоящий из трёх виртуальных машин:

* AlmaLinux 8 для обновления ядра из репозитория ELRepo
* Ubuntu 22.04 для обновления ядра ОС
* Centos 7 для ручного обновления ядра ОС

Клонируем репозиторий:

```bash
git clone
```

Выполняем команду:

```bash
vagrant up
```

## Обновление ядра AlmaLinux 8 из репозитория ELRepo

Виртуальная машина **"almalinux-kernel-update-elrepo"** была запущена в рамках этапа подготовки стенда.  
Чтобы посмотреть статус виртуальных машин, которыми управляет Vagrant, выполним команду:

```bash
vagrant status

Current machine states:
almalinux-kernel-update-elrepo  running (virtualbox)
centos-kernel-update            running (virtualbox)
ubuntu-kernel-update            running (virtualbox)
```

Если нашей машины нет в списке, выполним команду:

```bash
vagrant up almalinux-kernel-update-elrepo
```

### Обновим до ядра Linux 6.8

Мы используем репозиторий [ELRepo](https://elrepo.org), который является репозиторием сообщества для Enterprise Linux, обеспечивающим поддержку RedHat Enterprise (RHEL) и других дистрибутивов Linux на основе RHEL (CentOS, Scientific, Fedora и т.д.).  
ELRepo специализируется на программных пакетах, связанных с оборудованием.

По умолчанию в AlmaLinux 8 стоит ядро версии 4.18

```bash
uname -r
4.18.0-513.9.1.el8_9.x86_64
```

После перезагрузки виртуальной машины убедимся, что обновление ядра Linux прошло успешно. Зайдём на виртуальную машину:

```bash
vagrant ssh almalinux-kernel-update-elrepo
```

и выполним команду:

```bash
uname -r
6.8.0-060800-generic
```

### Подведение итога обновления ядра AlmaLinux 8 из репозитория ELRepo

* Версия ядра до обновления 4.18.0-513.9.1.el8_9.x86_64
* Установлено новое ядро из исходника версии 6.8
* Текущая версия ядра: 6.8.0-060800-generic

## Обновление ядра Ubuntu 22.04 до новой версии

Виртуальная машина **"ubuntu-kernel-update"** была запущена в рамках этапа подготовки стенда.  
Если нашей машины нет в списке, выполним команду:

```bash
vagrant up ubuntu-kernel-update
```

### Обновим Ubuntu 22.04 до ядра Linux 6.8

По умолчанию в Ubuntu 22.04 стоит ядро версии 5.15

```bash
uname -r
5.15.0-92-generic
```

Разработчики Ubuntu позаботились о том чтобы их пользователи не собирали ядро вручную и сделали deb пакеты новой версии ядра. Их можно скачать с официального сайта [Canonical](http://kernel.ubuntu.com/~kernel-ppa/mainline/). Здесь находятся все, собираемые командой Ubuntu ядра.

После перезагрузки виртуальной машины убедимся, что обновление ядра Linux прошло успешно. Зайдём на виртуальную машину:

```bash
vagrant ssh ubuntu-kernel-update
```

и выполним команду:

```bash
uname -r
6.8.0-060800-generic
```

### Подведение итога

* Версия ядра до обновления 5.15.0-92-generic
* Установлено новое ядро из исходника версии 6.8
* Текущая версия ядра: 6.8.0-060800-generic

## Обновление ядра CentOS 7 до версии 5.5.2

Виртуальная машина **"centos-kernel-update"** была запущена в рамках этапа подготовки стенда.  
Если нашей машины нет в списке, выполним команду:

```bash
vagrant up centos-kernel-update
```

### Обновим CentOS 7 до ядра Linux 5.5.2

По умолчанию в CentOS 7 стоит ядро версии 3.10

```bash
uname -r
3.10.0-957.12.2.el7.x86_64
```

Синхронизируем списки пакетов и репозиториев и обеспечим их актуальность. Обновим пакеты до последних версий. Установим базовые пакеты, утилиты и новые пакеты, если они требуются в качестве зависимостей:

```bash
sudo yum -y update
sudo yum -y install mc
sudo yum -y install wget ncurses-devel bc vim make gcc bison flex elfutils-libelf-devel openssl-devel grub2
```

Загрузим ядро с помощью команды wget в каталог **/usr/src/**  
Извлечём архивные файлы и сменим каталог, используя следующие команды:

```bash
sudo wget -q -P /usr/src/ https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.5.2.tar.xz
cd /usr/src/
sudo tar -C /usr/src/ --xz -xf linux-5.5.2.tar.xz
cd /usr/src/linux-5.5.2/
```

Скопируем текущую конфигурацию ядра (.config) из каталога /boot в новый каталог. Оставим все настройки со старого файла .config, и установим новые настройки в их рекомендуемое значение (т.е. в значение по умолчанию).  
На возникающие вопросы жмём Enter:

```bash
sudo cp -v /boot/config-$(uname -r) ./.config
sudo make olddefconfig
sudo scripts/config --disable SYSTEM_TRUSTED_KEYS
sudo scripts/config --disable SYSTEM_REVOCATION_KEYS
```

Перед началом компиляции ядра убедимся, что наша система имеет более 25 ГБ свободного места в файловой системе.  
Проверим свободное пространство файловой системы, используя команду df:

```bash
df -h
```

Скомпилируем и установим ядро ​​и модули, используя следующие команды (это займёт несколько часов). Процесс компиляции помещает файлы в каталог /boot, а также создает новую запись ядра в файле grub.conf.  
Отправляем команды в консоль, и ожидаем завершения процесса установки:

```bash
sudo make -j$(nproc)
sudo make modules_install
sudo make headers_install
sudo make install
```

Выполняем команду на применение внесённых нами изменений настроек grub:

```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

Укажем загрузчику grub, чтобы по умолчанию, загружалось наше новое ядро.  
Цифра 0 - это последнее установленное ядро, а установка его на 0 означает загрузку с новой версией ядра:

```bash
sudo grub2-set-default 0
```

Выполним перезагрузку:

```bash
sudo shutdown -r now
```

После перезапуска операционной системы, выполняем знакомую нам команду, чтобы узнать используемое системой ядро Linux:

```bash
uname -r
5.5.2
```

### Подведение итога обновления ядра CentOS 7

* Версия ядра до обновления 3.10.0-957.12.2.el7.x86_64
* Установлено новое ядро из исходника версии 5.5.2
* Текущая версия ядра: 5.5.2