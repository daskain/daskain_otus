# daskain_otus
# Выпускная работа по курсу DevOps практики и инструменты

<a name="description">## Описание</a> 
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

Оба сервиса развернуты на отдельных инстансах в Яндекс.Облаке


и там где это необходимо, ссылку на этот якорь:

[Текст ссылки](#твоё_название)