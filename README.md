# daskain_otus
# Выпускная работа по курсу DevOps практики и инструменты

##Описание
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

### Инструменты

## Terraform

Сервера создаются в Яндекс.Облаке через Terrafrom. Для инфраструктуры возможно создание среды stage и prod. Наборы манифестов разбиты по папкам. Компоненты подключены через модули.

Для K8s за основу взят манифест из документации Облака

Файлы находятся в папке:
```
./daskain_otus/terraform
```

## Ansible

Настройка развернутых серверов происходит через плэйбуки Ansible. Использованы роли и динамичное инвентори. Для корректной работы нужно сопоставить название папок в облаке:
- default - класстер K8s
- infra - ВМ с сервисами

## Helm

Для разворачивнаия мониторинга и приложения использется установка чартов через helm

## Мониторинг

Мониторинг реализован чартом prometheus-community/kube-prometheus-stack.
Стэк включает в себя prometheus, grafana. Возможно расширение до alertmanager и т.д.
Метрики собираются как с класстера K8s, серверов Mongo/RabbitMQ, так и приложения

## Gitlab

Управление жизненным циклом приложения реализованно в Gitlab. 

### Установка

## Инфраструктура

Для начала необходимо указать переменные для Terrafrorm. 

# Класстер k8s

Файлы находятся в папке **./daskain_otus/terraform/k8s/**:
- key.json - JSON Web Token для сервисного аккаунта.
- terraform.tfvars - переменные для развертывания.

# Инфраструктура

Общая папка **./daskain_otus/terraform/infra/**. Следуем менять перменные для каждой среды (prod/stage):
- key.json - JSON Web Token для сервисного аккаунта.
- terraform.tfvars - переменные для развертывания.



