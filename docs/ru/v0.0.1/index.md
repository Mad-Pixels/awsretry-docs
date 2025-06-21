---
layout: home
hero:
 name: "AWS-Retry"
 text: "Go библиотека для повторных запросов к AWS API"
 actions:
   - theme: brand
     text: Использование 
     link: ./guide/usage
   - theme: brand
     text: Референс
     link: ./reference/lib
   - theme: alt
     text: Релизы
     link: https://github.com/Mad-Pixels/awsretry/releases
   - theme: alt
     text: Исходный код
     link: https://github.com/Mad-Pixels/awsretry
 image: /logo.png
features:
- title: Без зависимостей
  details: Чистая реализация на стандартной библиотеке Go и smithy-go без внешних зависимостей
- title: Гибкие коллбэки
  details: Интеграция с любым фреймворком логирования через настраиваемые коллбэки для событий повторов
- title: Полное покрытие ошибок
  details: Предопределенные наборы ошибок, оптимизированные для DynamoDB, S3, Kinesis и всех сервисов AWS
- title: Умная экспоненциальная задержка
  details: Настраиваемые стратегии повторов с экспоненциальной задержкой
---