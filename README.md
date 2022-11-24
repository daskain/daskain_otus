# Выпускная работа по курсу DevOps практики и инструменты
## Описание
### Приложение
Приложение Crawler-app, состоит из двух комопонетов:
 1. **сrawler-engine** - сервис отвечает за парсинг html-страницы. Агрегирует ссылки и компонует из связанные списки;
 2. **crawler-UI** - html форма для поиска, возвращет список URL (распарсеных crawler-engine), на которых есть упоминание аргумента поиска.

***Репозитории сервиса***

[![Readme Card](https://github-readme-stats.vercel.app/api/pin/?username=daskain&repo=search_engine_crawler)](https://github.com/express42/search_engine_crawler)

[![Readme Card](https://github-readme-stats.vercel.app/api/pin/?username=daskain&repo=search_engine_ui)](https://github.com/express42/search_engine_ui)


### Инфрастуктура
Для функционирования приложения необходимы компоненты:
1. **RabbitMQ** - брокер сообщений для сrawler-engine;
2. **MongoDB** - NoSQL БД для обоих компонентов приложения.
3. **Gitlab** - инструмент для управления жизненным циклом.

Сервисы развернуты на отдельных инстансах в Яндекс.Облаке. Создание происходит через Terraform + Ansible


### Класстер K8s
Оркестарция реализована через кластер K8s. Развернут в Яндекс.Облаке. Создание происходит чере Terraform. Дополнительные компоненты ставятся bash-скриптом.


## Инструменты
### Terraform
Сервера создаются в Яндекс.Облаке через Terrafrom. Для инфраструктуры возможно создание среды stage и prod. Наборы манифестов разбиты по папкам. Компоненты подключены через модули.

Для K8s за основу взят манифест из документации Облака
Файлы находятся в папке:
```
~/daskain_otus/terraform
```


### Ansible
Настройка развернутых серверов происходит через плэйбуки Ansible. Использованы роли и динамичное инвентори. Для корректной работы нужно сопоставить название папок в облаке:
- default - класстер K8s
- infra - ВМ с сервисами


### Helm
Для разворачивнаия мониторинга и приложения использется установка чартов через helm


### Мониторинг
Мониторинг реализован чартом prometheus-community/kube-prometheus-stack.
Стэк включает в себя prometheus, grafana. Возможно расширение до alertmanager и т.д.
Метрики собираются как с класстера K8s, серверов Mongo/RabbitMQ, так и приложения


### Gitlab
Управление жизненным циклом приложения реализованно в Gitlab. 

### Стэк ELK
Логирование выполнено стеком ELK. Сервис устанавливается в кластер кубера.

## Установка
### Инфраструктура
#### Переменные
Для начала необходимо указать переменные для Terrafrorm. 

***Класстер k8s***

Файлы находятся в папке **~/daskain_otus/terraform/k8s/**:
- key.json - JSON Web Token для сервисного аккаунта.
- terraform.tfvars - переменные для развертывания.

***Инфраструктура***

Общая папка **~/daskain_otus/terraform/infra/**. Следуем менять перменные для каждой среды (prod/stage):
- key.json - JSON Web Token для сервисного аккаунта.
- terraform.tfvars - переменные для развертывания.

#### Развертывание
Для начала следует подготовить все компоненты. Есть несколько вариантов
***Скриптами***

После установки переменных, необходимо создать инстансы можно через скрипт:
```
~/daskain_otus/scripts/create_servers.sh
```
Получить token для раннера и хост Gitlab. Отредактировать файл ***~/daskain_otus/kuber/manifests/values.yaml***
Запустить скрипт prepare_k8s.sh:
```
$~/daskain_otus/scripts/prepare_k8s.sh
```

***Вручную***

Порядок действий:
 1. Создаем кластера K8s:
    ```
    $cd ~/daskain_otus/terrafrom/k8s
    $terraforn init
    $terraform apply --terraform apply --auto-approve 
    ```
 2. Импортировать конфигурацию кластера для kubectl:
    ```
    $yc managed-kubernetes cluster get-credentials \
    --folder-name $K8S_FOLDER_NAME \
    --cloud-id $K8S_CLOUD_ID \
    --external $K8S_MASTER_NODE \
    --force
    ```
 3. Создать ВМ для инфраструктуры в выбранной среде:
    ```
    #Для prod
    $cd ~/daskain_otus/terrafrom/infra/prod
    #Для stage
    $cd ~/daskain_otus/terrafrom/infra/stage
    $terraforn init
    $terraform apply --terraform apply --auto-approve 
    ```
 4. Подготовить сервисы на созданных ВМ:
    ```
    $cd ~/daskain_otus/ansible/
    #По умолчанию PROD
    $ansible-playbook playbooks/prepare_infra.yml
    #Для stage
    $ansible-playbook -i ./environments/stage/get_inventory.py ./playbooks/prepare_infra.yml
    ```
 5. Получить token для раннера и хост Gitlab. Отредактировать файл ***~/daskain_otus/kuber/manifests/values.yaml***
    Запустить скрипт prepare_k8s.sh:
    ```
    #Установка Ingress Contorller:
    $kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml

    #Создание и выдача прав для пользователя gitlab-admin:
    $kubectl create clusterrolebinding gitlab-admin --clusterrole=cluster-admin --group=system:serviceaccounts

    #Установка раннера
    $helm upgrade --namespace default gitlab-runner -f values.yaml gitlab/gitlab-runner -i

    #Создание пространства имен monitoring
    $kubectl create namespace monitoring

    #Создание пространства имен logging
    $kubectl create namespace logging
    ```

После подгтовки, можно заняться приложением:
 - Создать проект crawler-app, elk и monitoring
 - Запушить содержимое папок ./monitoring, ./elk и ./kuber/crawler-app в гитлаб

Проверить работоспособность