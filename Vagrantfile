# -*- mode: ruby -*-
# vi: set ft=ruby :

# ЗАВОРАЧИВАЕМ ПУТЬ В ПЕРЕМЕННУЮ:
current_dir = File.join(File.dirname(__FILE__))

# ПОДКЛЮЧАЕМ И ЧИТАЕМ YAML-ФАЙЛ С НАСТРОЙКАМИ:
require 'yaml'
if File.file?("#{current_dir}/nodes/config/vagrant-config-nodes.yaml") && File.file?("#{current_dir}/nodes/config/vagrant-config-global.yaml")
  confignodes   = YAML.load_file("#{current_dir}/nodes/config/vagrant-config-nodes.yaml")
  configglobal  = YAML.load_file("#{current_dir}/nodes/config/vagrant-config-global.yaml")
else
  raise "Некоторые важные конфигурационные файлы отсутствуют"
end

# ПРОВЕРЯЕМ, УСТАНОВЛЕНЫ ЛИ НЕОБХОДИМЫЕ ПЛАГИНЫ
required_plugins = ["vagrant-disksize"]
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure("#{configglobal["GLOBAL"]["api_version"]}") do |config|
  # ПРОХОДИМ ПО ЭЛЕМЕНТАМ МАССИВА ИЗ YAML-ФАЙЛА С НАСТРОЙКАМИ:
  #   глобальная инициализация будет выполняться сначала для каждой из виртуальных машин, а затем будет инициализация 
  #   с ограниченной областью действия. Поместив контроллер в конец списка, он будет последним, для которого выполняется 
  #   инициализация. Вы можете упорядочить загрузку, изменив порядок из списка и создав дополнительные условия. 
  confignodes["nodes"].each do |confignodes|
    if confignodes["setup"] == true
      config.vm.define confignodes["name"] do |vm|
        #   если определена переменная образа системы в файле vagrant-config-nodes.yaml для данной виртуальной машины, то:
        if confignodes["box"]
          vm.vm.box = confignodes["box"]
          vm.vm.box_version = confignodes["box_version"]
        #   иначе образ из глобального файла настроек vagrant-config-global.yaml
        else
          vm.vm.box = configglobal["GLOBAL"]["box"]
          vm.vm.box_version = configglobal["GLOBAL"]["box_version"]
        end
        vm.vm.hostname = "#{confignodes["domain_prefix"]}#{configglobal["GLOBAL"]["domain_suffix"]}"
        if confignodes["disksize"]
          vm.disksize.size = confignodes["disksize"]
        end
        
        # ТРИГГЕРЫ:
        #   перед каждым vagrant up за исключением vagrant destroy, vagrant halt персонально для каждой из виртуальных машин
        vm.trigger.before :all do |trigger|
          trigger.name = "Start message"
          trigger.info = "\n\e[31m#{confignodes["description"]}\e[0m\n"
          trigger.ignore = [:destroy, :halt, :config_validate]
        end
        #   после каждого vagrant up персонально для каждой из виртуальных машин
        if File.file?("#{current_dir}/nodes/roles/#{confignodes["name"]}/vagrant-up-after.sh")
          vm.trigger.after :up do |trigger|
            trigger.name = "Finished message"
            trigger.info = "\n\e[31m#{confignodes["description"]}\e[0m\n"
            trigger.run_remote  = {path: "#{current_dir}/nodes/roles/#{confignodes["name"]}/vagrant-up-after.sh"}
          end
        end

        # РАСШИРЕННАЯ КОНФИГУРАЦИЯ:
        #   Провайдер (англ. Provider) представляет собой программное обеспечение для создания и управления виртуальными машинами, используемыми в Vagrant. 
        #   Основыными провайдерами являются Virtualbox и VMware.
        if configglobal["GLOBAL"]["vagrant_provider"] == "virtualbox"
          memory = confignodes["memory"]  ? confignodes["memory"]  : 2048;
          cpu = confignodes["cpu"]  ? confignodes["cpu"]  : 1;
          name = confignodes["name"];
          vm.vm.provider :virtualbox do |vb|
            vb.customize [
              "modifyvm", :id,
              "--cableconnected1", "on",
              "--memory", memory.to_s,
              "--cpus", cpu.to_s,
              "--name", name
            ]
          end
        elsif configglobal["GLOBAL"]["vagrant_provider"] == "vmware_fusion"
        elsif configglobal["GLOBAL"]["vagrant_provider"] == "docker"
        elsif configglobal["GLOBAL"]["vagrant_provider"] == "hyperv"
        elsif configglobal["GLOBAL"]["vagrant_provider"] == "parallels"
        end
        
        # НАСТРОЙКА SSH:
        #   В более ранних версиях Vagrant для подключения к виртуальной машине использовался ключ ~/.vagrant.d/insecure_private_key. 
        #   Но теперь Vagrant выдает предупреждение, что обнаружен небезопасный ключ и заменяет его:
        #   Vagrant insecure key detected. Vagrant will automatically replace
        #   this with a newly generated keypair for better security.
        #   Этот ключ расположен в где-то в недрах директрории .vagrant (создается после первого запуска vagrant up). Посмотреть, какой ключ 
        #   будет использован, можно с помощью команды: vagrant ssh-config
        #   Можно отменить создание ssh-ключа, если определить переменную в YAML-файле с настройками insert_key = false
        vm.vm.boot_timeout = 300
        # vm.ssh.keys_only  = confignodes["keys_only"]
        # vm.ssh.insert_key = confignodes["insert_key"]         
        
        # КОНФИГУРАЦИЯ СЕТИ:
        #   ПЕРЕНАПРАВЛЕНИЕ ПОРТОВ:
        #     настройка "forwarded_port" позволит нам открыть порт прослушивания в хост- и гостевой операционных системах. 
        #     Хост- операционная система пересылает все полученные пакеты на порт, который мы указываем для гостевой операционной системы.
        #     Эта настройка применяется для каждой из виртуальных машин.
        #     Параметр "auto_correct" означает, что если у вас где-то есть конфликт портов (пробросили на уже занятый порт), то vagrant это дело увидит и сам 
        #     исправит. Автоматически эта опция включена только для 22 порта, для портов, которые вы задаёте вручную, нужно указать эту опцию.
        #     Никогда не назначайте проброс портов на стандартные! (например, 22 на 22) Это чревато проблемами в хост- операционной системе.
        #     По-умолчанию проброс идёт ТСР протокола. Для того, чтоб проборосить UDP порт, это нужно явно указать:
        #     vm.vm.network "forwarded_port", guest: 35555, host: 12003, protocol: "udp" 
        vm.vm.network "forwarded_port", guest: confignodes["port_guest"], host: confignodes["port_host"], auto_correct: true
        #
        #   COCKPIT — инструмент для мониторинга и администрирования виртуальных серверов Linux через веб-браузер 
        #     Он представляет собой интерактивный веб-интерфейс, реализованный через LIVE-сеанс Linux в веб-браузере. 
        #     И позволяет осуществлять функции мониторинга и администрирования.
        #     По умолчанию, Cockpit работает на порту 9090
        if confignodes["port_web_based_interface"] && confignodes["web_based_interface"] == "cockpit"
          vm.vm.network "forwarded_port", guest: 9090, host: confignodes["port_web_based_interface"], 
          auto_correct: true
        end
        #
        #     Вообще говоря, перенаправления портов обычно бывает достаточно. Но для особых нужд вам может понадобиться полностью «настоящая» виртуальная машина, 
        #     к которой можно стабильно обращаться с хост-машины и к другим ресурсам в локальной сети. Такое требование фактически может быть решено путем 
        #     настройки нескольких сетевых карт, например, одна настроена в режиме частной сети, а другая - в режиме общедоступной сети.
        #     Vagrant может поддерживать сетевые модели виртуального бокса NAT, Bridge и Hostonly через файлы конфигурации.
        #   ЧАСТНАЯ СЕТЬ (Private network):
        #     С частной сетью понятно - мы делаем собственную сеть LAN, которая будет состоять из виртуальных машин. Для доступа к такой сети из хоста нужна 
        #     пробрасывать порт через Vagrantfile (или через Vbox, но через vagrant удобнее). А для доступа из реальной сети, то есть, например из другой 
        #     физической машины, мы должны будем стучаться на IP хоста. Это удобно, если создавать виртуалку для «поиграться» или если планируется использовать 
        #     виртуалку внутри сети и за NAT (например, она получит адрес от DHCP другой виртуалки, которая будет выполнять роль шлюза). IP можно не указывать, можно сделать так:
        #     vm.vm.network "private_network", type: "dhcp"
        #     и адрес назначится автоматически.
        if confignodes["ip_private"]
          vm.vm.network "private_network", ip: confignodes["ip_private"]
        end
        #   ПЕРЕНАПРАВЛЕНИЕ ПОРТОВ SSH:
        #     Подключиться к системе можно через SSH через vagrant@localhost
        #     Базовый логин и пароль на вход в систему — «vagrant: vagrant»
        if confignodes["port_ssh"]
          vm.vm.network "forwarded_port", id: "ssh", host: confignodes["port_ssh"], guest: 22
        end
        #   ПУБЛИЧНАЯ СЕТЬ (Public network):
        #     Публичная сеть означает, что виртуальная машина представлена ​​как хост в локальной сети, т.е. так, как будто появился новый сервер со своим адресом и именем.
        #     С публичной сетью нет необходимости пробрасывать порты - всё доступно по адресу виртуалки. Для всех машин в этой же подсети.
        #     Однако тут надо быть осторожным, так как это может создать некоторые проблемы с DNS и\или DHCP на основном шлюзе.
        #     Если не задать адрес, то он будет задан DHCP-сервером в реальной подсети. По факту, публичная сеть использует bridge-соединение с WAN-адаптером 
        #     хоста. Если у вас два физических адаптера (две сетевых карты, например проводная и беспроводная), то необходимо указать, какой использовать.
        if confignodes["ip_public"] && confignodes["ip_bridge"]
          vm.vm.network :public_network, ip: confignodes["ip_public"], bridge: confignodes["ip_bridge"]
        end
        
        # СИНХРОНИЗАЦИЯ ФАЙЛОВ ПРОЕКТА:
        #     Хорошей практикой является не копирование файлов проекта в виртуальную машину, а совместное использование файлов между хостом и 
        #     гостевыми операционными системами, потому что если вы удалите свою виртуальную машину, файлы будут потеряны вместе с ней.
        #     "Из коробки" vagrant синхронизирует каталог хоста с Vagrantfile в директорию /vagrant виртуальной машины.
        #     Если на хостовой машине указывать относительный путь, то корневым будет каталог с Vagrantfile. Путь на гостевой машине должен быть только абсолютный.
        #     Для того, чтоб указать дополнительный каталоги для синхронизации, нужно добавить следующую строку в Vagrantfile:
        #     vm.vm.synced_folder "src/", "/var/www/html" 
        #     Первым аргументом является папка на хост-машине, которая будет использоваться совместно с виртуальной машиной.
        #     Второй аргумент – это целевая папка внутри виртуальной машины.
        #     create: true указывает, что если целевой папки внутри виртуальной машины не существует, то необходимо создать ее автоматически.
        #     group: «www-data» и owner: «www-data» указывает владельца и группу общей папки внутри виртуальной машины. 
        #     По умолчанию большинство веб-серверов используют www-данные в качестве владельца, обращающегося к файлам.
        #     Дополнительные опции:
        #       disabled - если указать True, то синхронизация будет отключена. Удобно, если нам не нужна дефолтная синхронизация.
        #       mount_options - дополнительные параметры, которые будут переданы команде mount при монтировании
        #       type - полезная опция, которая позволяет выбрать тип синхронизации. Доступны следующие варианты:
        #         NFS (тип NFS доступен только для Linux хост- ОС);
        #         rsync;
        #         SMB (тип SMB доступен только для Windows хост- ОС);
        #         VirtualBox.
        #     Если эта опция не указана, то vagrant выберет сам подходящую.
        #   Отключаем дефолтные общие папки для каждой из виртуальных машин:
        # vm.vm.synced_folder ".", "/vagrant", disabled: true
        if confignodes["sync_folder"] && confignodes["sync_folde"] == true
          vm.vm.synced_folder "./www", "/var/www/html", disabled: true
          vm.vm.synced_folder "data-sync/#{confignodes["name"]}/", "/sync", 
            create: true
        end

        # КОНФИГУРАЦИЯ ВИРТУАЛЬНОЙ МАШИНЫ С ПОМОЩЬЮ SHELL:
        #   для конкретной вирутальной машины текущего элемента массива при каждой инициализации
        #   privileged - определяет, от какого пользователя запускать команду. По-умолчанию установленно True, что запустит скритп от root. Если команда должна 
        #   запускаться от стандартного пользователя (vagrant), то установите значения False.
        if File.file?("#{current_dir}/nodes/roles/#{confignodes["name"]}/vagrant-up.sh")
          vm.vm.provision "shell", path: "#{current_dir}/nodes/roles/#{confignodes["name"]}/vagrant-up.sh",
            env: {
            },
            run: "always", 
            privileged: true
        end
        if File.file?("#{current_dir}/nodes/roles/#{confignodes["name"]}/bootstrap.sh")
          vm.vm.provision "shell", path: "#{current_dir}/nodes/roles/#{confignodes["name"]}/bootstrap.sh",
            env: {

            }
        end
        
        # ПЕРСОНАЛЬНАЯ МАГИЯ:
        #   ТРИГГЕРЫ:
        #      ..
        #   ПРОБРОС ПОРТОВ:
        #      ..
        #   СИНХРОНИЗАЦИЯ ФАЙЛОВ ПРОЕКТА:
        #      ..
        #   ДОПОЛНИТЕЛЬНАЯ КОНФИГУРАЦИЯ ВИРТУАЛЬНОЙ МАШИНЫ С ПОМОЩЬЮ SHELL
        #     при первой загрузке
        #        ..
        #     при каждой загрузке:
        #        ..      
        if confignodes["name"] == "almalinux-kernel-update-elrepo"
        elsif confignodes["name"] == "ubuntu-kernel-update"
        elsif confignodes["name"] == "centos-kernel-update"
        end                 
      end
    end
  end
  # КОНФИГУРАЦИЯ ВИРТУАЛЬНОЙ МАШИНЫ С ПОМОЩЬЮ SHELL:
  #   для каждой из вирутальных машин при первой инициализации
  config.vm.provision "shell", path: "#{current_dir}/nodes/provision/provision.sh",
    env: {
    }
end