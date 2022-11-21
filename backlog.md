# step-1
## План
 - [x] Создать репозиторий
 - [x] Продумать структуру репозитория
 - [x] Создать структуру репозитория
 - [x] Подготовить манифесты для инстанса кубера

## Что сделано
Создал репозиторий. Выбрал следующую структуру:
 - terraform - папка с файлами для развертывания инстанса в Яндекс.Облаке
 - app - папка с файлами приложения
 - monitoring - папка с файлами для развертывания логирования и мониторинга приложения 

# step-2
## План
 - [x] Докеризация приложения
 - [x] Развернуть окружение для компонентов

 ## Что сделано
 Докеризировал приложение - ui и search

 Окружение:

 - Monga
 ```
 docker run -d --name mongodb -p 27017:27017 --network my-network  mongo:3.2
 ```

 - RabbitMQ
 ```
 docker run -d -p 8080:15672 --hostname my-rabbit --name my-rabbit -e RABBITMQ_DEFAULT_USER=user -e RABBITMQ_DEFAULT_PASS=password --network my-network rabbitmq:3-management

 ```

# step-3
## План
 - [x] Равезрнуть инфру в облаке
 - [x] Подружить приложение с кубером
 - [ ] Попробовать мониторинг

## Что сделано
### Равезрнуть инфру в облаке
Добавлены манифесты терраформа для разворачивания необходимой инфраструктуры:
 - сервер для mongo
 - сервер для rabbit

 Mongo и rabbit устанавливаются через ansible-playbook (по умолчанию окружение ПРОД). Несмотря на наличие двух окружений в ansible - они идентичны.
 Terraform:
```
$terraform apply -auto-approve
```
Ansible:
```
$ansible-playbook playbooks/prepare_infra.yml
```

### Подружить приложение с кубером
Для корректной работы, предварительно установим ingress-controller:
```
$kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml
```
Оба компоненты объеденены в один chart
```
$helm dep update ./crawler-app/
```

Параметры приложения заданы через глобальный файл конфигурации values.yaml

Установка:
```
$helm install crawler-app-1 ../crawler-app
$helm ls
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/daskain/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/daskain/.kube/config
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
crawler-app-1   default         1               2022-11-15 14:17:10.60055078 +0300 MSK  deployed        crawler-app-1              
crawler-app-2   default         1               2022-11-15 14:18:36.217981051 +0300 MSK deployed        crawler-app-1              
crawler-app-4   default         1               2022-11-15 14:19:40.898172642 +0300 MSK deployed        crawler-app-1              
crawler-app-5   default         1               2022-11-15 14:19:45.272737804 +0300 MSK deployed        crawler-app-1   
```
Доступ к приложению осуществляется через:
 - ui IP_INGRESS/NAME_OF_INSTALL/ui
 - crawler IP_INGRESS/NAME_OF_INSTALL/crawler

 Где:
  - IP_INGRESS - ip ingress-controller
  - NAME_OF_INSTALL - имя инсталяции

### Попробовать мониторинг
Мониторинг переезжает в следующий  step-4


# step-4
## План
 - [х] Доработка развертывания
 - [ ] Интегрировать c gitlab
 - [ ] Настроить мониторинг


## Что сделано
### Доработка развертывания
Добавлен +1 хост для гитлаба. Создание все серверов и их удаление теперь осуществляется с двух скриптов:
```
$tree scripts/
scripts/
├── create_servers.sh
└── destroy_servers.sh

0 directories, 2 files
```

Сразу после создания хостов из infra, запускается ansible, который разворачивает необходимые приложения
После установки кубера - импортируется конфига и устанавливается ingress

### Интегрировать c gitlab
Приложение развертывается через gitlab pipelne. Есть инсталяция через helm и проверка состояния деплоя кажого компонента
