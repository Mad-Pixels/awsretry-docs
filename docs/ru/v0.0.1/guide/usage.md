# Использование
Полное руководство по использованию библиотеки `awsretry` для обработки повторных попыток AWS операций.

## Установка

```bash
go get github.com/Mad-Pixels/awsretry@v0.0.1
```
::: tip Требования
Минимальная версия Go: 1.24+
:::

## Быстрый старт
### Базовое использование
```go
func main() {
  // Простой повтор с настройками по умолчанию
  result, err := awsretry.ExecuteWithRetry(ctx,
    func(ctx context.Context) (*dynamodb.GetItemOutput, error) {
      return client.GetItem(ctx, input)
    },
    awsretry.DefaultRetryConfig(),
    nil, // без коллбэков
  )
  if err != nil {
    log.Fatal(err)
  }
   
  fmt.Println("Success:", result)
}
```
::: info Что происходит?
- Максимум 3 повтора после первой попытки
- Начальная задержка 100ms с множителем 1.5
- Повторяются только ошибки ограничения скорости
- Без логирования
:::

## Конфигурация
### Настройки по умолчанию
```go
config := awsretry.DefaultRetryConfig()
// MaxRetries: 3
// BaseDelay: 100ms  
// MaxDelay: 1s
// Multiplier: 1.5
// RetryableErrors: RateLimitErrors
```

### Пользовательская конфигурация
::: code-group
```go [Агрессивная]
config := awsretry.NewRetryConfig(
  5,                           // максимум 5 повторов
  200*time.Millisecond,        // начинаем с 200ms
  5*time.Second,               // максимум 5s задержка
  2.0,                         // удваиваем каждый раз
  awsretry.TemporaryErrors,    // все временные ошибки
)
```

```go [Консервативная]
config := awsretry.NewRetryConfig(
  2,                           // всего 2 повтора
  500*time.Millisecond,        // начинаем с 500ms
  2*time.Second,               // максимум 2s
  1.2,                         // медленный рост
  awsretry.ConservativeErrors, // только безопасные ошибки
)
```

```go [DynamoDB]
config := awsretry.NewRetryConfig(
  4,
  100*time.Millisecond,
  time.Second,
  1.5,
  awsretry.DynamoDBErrors,     // ошибки DynamoDB
)
```
:::

## Логирование и мониторинг
### Простое логирование
```go
callbacks := awsretry.NewRetryCallbacks().
  WithOnRetry(
    func(
      attempt int, 
      err error, 
      delay time.Duration, 
      errorCode string,
    ) {
      log.Printf("Попытка %d: %s (задержка: %v, код: %s)", attempt, err, delay, errorCode)
  })

result, err := awsretry.ExecuteWithRetry(ctx, operation, config, callbacks)
```

### Полное логирование
```go
callbacks := awsretry.NewRetryCallbacks().
  WithOnRetry(
    func(
      attempt int, 
      err error, 
      delay time.Duration, 
      errorCode string,
    ) {
      log.Printf("🔄 Повтор %d: %s (задержка: %v, код: %s)", attempt, err, delay, errorCode)
    },
  ).
  WithOnSuccess(
    func(totalAttempts int) {
      log.Printf("✅ Успех после %d попыток", totalAttempts)
    },
  ).
  WithOnFailure(
    func(
      totalAttempts int, 
      finalErr error, 
      reason string,
    ) {
      log.Printf("❌ Провал после %d попыток: %s (%s)", totalAttempts, finalErr, reason)
    },
  )
```

### Интеграция с логгерами
::: code-group

```go [Zap]
import "go.uber.org/zap"

logger, _ := zap.NewProduction()
callbacks := awsretry.NewRetryCallbacks().
  WithOnRetry(func(attempt int, err error, delay time.Duration, errorCode string) {
    logger.Warn("AWS operation retry",
    zap.Int("attempt", attempt),
    zap.Error(err),
    zap.Duration("delay", delay),
    zap.String("error_code", errorCode),
  )
})
```

```go [Logrus]
import "github.com/sirupsen/logrus"

callbacks := awsretry.NewRetryCallbacks().
  WithOnRetry(func(attempt int, err error, delay time.Duration, errorCode string) {
    logrus.WithFields(logrus.Fields{
      "attempt":    attempt,
      "error":      err,
      "delay":      delay,
      "error_code": errorCode,
    }).Warn("AWS operation retry")
  })
```

```go [etc]
callbacks := awsretry.NewRetryCallbacks().
  WithOnRetry(func(attempt int, err error, delay time.Duration, errorCode string) {
    slog.Warn("AWS retry",
      "attempt", attempt,
      "error", err.Error(),
      "delay_ms", delay.Milliseconds(),
      "aws_error_code", errorCode,
    )
  })
```
:::

## Выбор ошибок для повтора
### Предопределенные наборы
::: tip Рекомендации
- **TemporaryErrors** - для большинства случаев
- **ConservativeErrors** - для критических операций  
- **DynamoDBErrors** - для DynamoDB операций
- **S3Errors** - для S3 операций
:::

::: code-group

```go [Все временные ошибки]
config := awsretry.NewRetryConfig(
  3, 
  100*time.Millisecond, 
  time.Second, 1.5, 
  awsretry.TemporaryErrors,
) // Рекомендуется
```

```go [Только троттлинг]
config := awsretry.NewRetryConfig(
  5, 
  50*time.Millisecond, 
  500*time.Millisecond, 
  2.0,
  awsretry.RateLimitErrors,
) // Только ограничения скорости
```

```go [Пользовательский набор]
customErrors := []string{
  "Throttling", 
  "ServiceUnavailable", 
  "MyCustomError",
}

config := awsretry.NewRetryConfig(
  3, 
  100*time.Millisecond, 
  time.Second, 
  1.5, 
  customErrors,
)
:::

## Примеры для разных сервисов AWS
### DynamoDB
::: code-group

```go [GetItem]
import "github.com/aws/aws-sdk-go-v2/service/dynamodb"

config := awsretry.NewRetryConfig(
  5, 
  100*time.Millisecond, 
  time.Second, 
  2.0, 
  awsretry.DynamoDBErrors,
)

result, err := awsretry.ExecuteWithRetry(ctx,
  func(ctx context.Context) (*dynamodb.GetItemOutput, error) {
    return dynamoClient.GetItem(ctx, &dynamodb.GetItemInput{
      TableName: aws.String("users"),
      Key: map[string]types.AttributeValue{
        "id": &types.AttributeValueMemberS{Value: "user123"},
      },
    })
  }, config, nil)
```

```go [BatchWriteItem]
batchConfig := awsretry.NewRetryConfig(
  4, 
  200*time.Millisecond, 
  2*time.Second, 
  1.5, 
  awsretry.DynamoDBErrors,
)

_, err := awsretry.ExecuteWithRetry(ctx,
  func(ctx context.Context) (*dynamodb.BatchWriteItemOutput, error) {
    return dynamoClient.BatchWriteItem(ctx, &dynamodb.BatchWriteItemInput{
      RequestItems: batchRequests,
    })
  }, batchConfig, callbacks)
```
:::

### S3
::: code-group
```go [GetObject]
import "github.com/aws/aws-sdk-go-v2/service/s3"

s3Config := awsretry.NewRetryConfig(
  3, 
  200*time.Millisecond, 
  5*time.Second, 
  1.5, 
  awsretry.S3Errors,
)

result, err := awsretry.ExecuteWithRetry(ctx,
  func(ctx context.Context) (*s3.GetObjectOutput, error) {
    return s3Client.GetObject(ctx, &s3.GetObjectInput{
      Bucket: aws.String("my-bucket"),
      Key:    aws.String("path/to/file.txt"),
    })
  }, s3Config, nil)
```

```go [PutObject]
_, err := awsretry.ExecuteWithRetry(ctx,
  func(ctx context.Context) (*s3.PutObjectOutput, error) {
    return s3Client.PutObject(ctx, &s3.PutObjectInput{
      Bucket: aws.String("my-bucket"),
      Key:    aws.String("uploads/file.txt"),
      Body:   bytes.NewReader(data),
    })
  }, s3Config, callbacks)
```
:::

## Продвинутые сценарии
### Работа с контекстом

::: code-group
```go [С таймаутом]
// Операция прервется через 30 секунд
ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()

result, err := awsretry.ExecuteWithRetry(ctx, operation, config, callbacks)
if errors.Is(err, context.DeadlineExceeded) {
   log.Println("Операция прервана по таймауту")
}
```

```go [С отменой]
ctx, cancel := context.WithCancel(context.Background())

// В другой горутине
go func() {
  time.Sleep(5 * time.Second)
  cancel() // Отменяем операцию
}()

result, err := awsretry.ExecuteWithRetry(ctx, operation, config, callbacks)
if errors.Is(err, context.Canceled) {
  log.Println("Операция отменена")
}
```
:::

### Условные повторы
```go
// Повторяем только определенные ошибки
customConfig := awsretry.NewRetryConfig(
  3, 
  100*time.Millisecond, 
  time.Second, 
  1.5, 
  []string{"SpecificError", "AnotherError"}),
)

// Или создаем функцию-обертку для сложной логики
func retryWithCondition(ctx context.Context, operation func(ctx context.Context) (string, error)) (string, error) {
  return awsretry.ExecuteWithRetry(ctx,
    func(ctx context.Context) (string, error) {
      result, err := operation(ctx)
      if err != nil {
        // Дополнительная проверка
        if strings.Contains(err.Error(), "temporary") {
          return "", err // Повторим
        }
        // Превращаем в неповторяемую ошибку
        return "", fmt.Errorf("permanent error: %w", err)
      }
      return result, nil
    }, customConfig, nil)
}
```

### Метрики и мониторинг
```go
type MetricsCallbacks struct {
  retryCounter   prometheus.Counter
  successCounter prometheus.Counter
  failureCounter prometheus.Counter
}

func (m *MetricsCallbacks) OnRetry(attempt int, err error, delay time.Duration, errorCode string) {
  m.retryCounter.Inc()
}

func (m *MetricsCallbacks) OnSuccess(totalAttempts int) {
  m.successCounter.Inc()
}

func (m *MetricsCallbacks) OnFailure(totalAttempts int, finalErr error, reason string) {
  m.failureCounter.Inc()
}

// Использование
metricsCallbacks := &MetricsCallbacks{
  retryCounter:   prometheus.NewCounter(/* ... */),
  successCounter: prometheus.NewCounter(/* ... */),
  failureCounter: prometheus.NewCounter(/* ... */),
}

callbacks := &awsretry.RetryCallbacks{
  OnRetry:   metricsCallbacks.OnRetry,
  OnSuccess: metricsCallbacks.OnSuccess,
  OnFailure: metricsCallbacks.OnFailure,
}
```

## Лучшие практики

### ✅ Делайте

::: tip Рекомендации
- Используйте **TemporaryErrors** для большинства случаев
- Устанавливайте разумные **MaxDelay** (1-10 секунд)
- Логируйте повторы для отладки
- Учитывайте таймауты контекста
- Тестируйте поведение повторов
:::

### ❌ Избегайте

::: danger Не делайте так
- Не устанавливайте слишком много повторов (>10)
- Не игнорируйте контекст отмены
- Не повторяйте невосстановимые ошибки
- Не забывайте про MaxDelay
- Не используйте повторы для валидационных ошибок
:::

## Понимание задержек
### Экспоненциальный отступ
Формула: `delay = BaseDelay × (Multiplier ^ attempt)`
::: details Пример расчета
При BaseDelay=100ms, Multiplier=1.5:
- Попытка 1: 100ms × 1.5⁰ = 100ms
- Попытка 2: 100ms × 1.5¹ = 150ms  
- Попытка 3: 100ms × 1.5² = 225ms
- Попытка 4: 100ms × 1.5³ = 337ms
:::
