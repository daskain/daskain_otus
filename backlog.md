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
 - [x] Доработка развертывания
 - [x] Интегрировать c gitlab
 - [x] Настроить мониторинг


## Что сделано
### Доработка развертывания
Добавлен +1 хост для гитлаба. Создание всеx серверов и их удаление теперь осуществляется скриптами create_servers.sh и destroy_servers.sh:
```
$tree scripts/
scripts/
├── create_servers.sh
├── destroy_servers.sh
└── prepare_k8s.sh

0 directories, 3 files
```
После подготовки серверов и кластера K8S, необходимо подготовить Gitlab (раннеры, проекты и группы):
 - Зайти на хост Gitlab, ввести креды
 - Создать группу
 - Взять токен для раннера
 - Создать проект crawler-app и monitoring
 - Запушить содержимое папок ./monitoring и ./kuber/crawler-app в гитлаб

Токена и адрес хоста Gitlab необходимо добавить в файл ./kuber/manifests/values.yaml. После чего запустить скрипт:
```
$./scripts/prepare_k8s.sh 
```
Раннер добавится в gitlab, где его надо будет настроить на работу с тегами (в пайпе приложения добавлены теги)

### Интегрировать c gitlab
Для развертывания проектов используется gitlab pipeline. Реализовано несколько стадий, работа с разными средами (условно, т.к. по сути они смотрят на те-же сервера Mongo/RabbitMQ)

### Мониторинг
Мониторинг реализован через chart prometheus-community/kube-prometheus-stack.
Grafana и Prometheus доступны через LoadBalance:
```
$kubectl get svc -n monitoring
NAME                                      TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
alertmanager-operated                     ClusterIP      None            <none>           9093/TCP,9094/TCP,9094/UDP   91m
prometheus-operated                       ClusterIP      None            <none>           9090/TCP                     91m
stable-grafana                            LoadBalancer   10.96.194.57    51.250.79.93     80:30872/TCP                 91m
stable-kube-prometheus-sta-alertmanager   ClusterIP      10.96.128.25    <none>           9093/TCP                     91m
stable-kube-prometheus-sta-operator       ClusterIP      10.96.180.72    <none>           443/TCP                      91m
stable-kube-prometheus-sta-prometheus     LoadBalancer   10.96.211.143   158.160.38.195   9090:32425/TCP               91m
stable-kube-state-metrics                 ClusterIP      10.96.138.96    <none>           8080/TCP                     91m
stable-prometheus-node-exporter           ClusterIP      10.96.219.206   <none>           9100/TCP                     91m
```
Креды для Grafana:
```
UserName: admin
Password: prom-operator
```


# step-5
## План
 - [x] Добавлен мониторинг MongoDB/RabbitMq
 - [x] Добавить логирование ELK
 - [x] Подготовить проект к защите

### Добавлен мониторинг MongoDB/RabbitMq
Добавлен мониторинг компоненток.Используются чарты:
```
prometheus-community/prometheus-mongodb-exporter 
rometheus-community/prometheus-rabbitmq-exporter
```

Параметры ВМ устанавливаюся в переменных:
 - values.mongodb.yaml - для MongoDB
 - values.rabbitmq.yaml - для RabbitMQ

Установка происходит в момент развертывания мониторинга


### Добавить логирование ELK
Добавлено логирование стэком ELK - elasticksearch, kibana, fluentd
Манифесты расположены в ./elk/
В гитлаб добавлен проект elk, с пайплайнами установки мониторинга. Kibana доступна по внешнему IP.


### Подготовить проект к защите
Подготовлена презентация
