# Референс

## Основные функции

### NewRetryConfig
```go
func NewRetryConfig(
  maxRetries int, 
  baseDelay time.Duration, 
  maxDelay time.Duration, 
  multiplier float64, 
  retryableErrors []string,
) RetryConfig
```
Создает пользовательскую конфигурацию повторов.

### DefaultRetryConfig
```go
func DefaultRetryConfig() RetryConfig
```
Создает стандартную конфигурацию:
- 3 повтора максимум
- Начальная задержка 100ms
- Максимальная задержка 1s
- Множитель 1.5
- Повторяет RateLimitErrors

### ExecuteWithRetry
```go
func ExecuteWithRetry[T any](
  ctx context.Context,
  operation func(ctx context.Context) (T, error),
  config RetryConfig,
  callbacks *RetryCallbacks,
) (T, error)
```
Выполняет операцию с повторными попытками при ошибках AWS.

### NewRetryCallbacks
```go
func NewRetryCallbacks() *RetryCallbacks
```
Создает пустые коллбэки для отслеживания событий повторов.

## Типы

### RetryConfig

```go
type RetryConfig struct {
  MaxRetries      int           // Максимум повторов после первой попытки
  BaseDelay       time.Duration // Начальная задержка
  MaxDelay        time.Duration // Максимальная задержка
  Multiplier      float64       // Множитель для экспоненциального роста
  RetryableErrors []string      // Коды ошибок AWS для повтора
}
```

### RetryCallbacks
```go
type RetryCallbacks struct {
  OnRetry   func(attempt int, err error, delay time.Duration, errorCode string)  // Вызывается перед каждым повтором
  OnSuccess func(totalAttempts int)                                              // Вызывается при успехе
  OnFailure func(totalAttempts int, finalErr error, reason string)               // Вызывается при провале
}
```

#### Методы RetryCallbacks
```go
func (rc *RetryCallbacks) WithOnRetry(
  fn func(
    attempt int, 
    err error, 
    delay time.Duration, 
    errorCode string,
  ),
) *RetryCallbacks
```
Устанавливает коллбэк для повторов.

```go
func (rc *RetryCallbacks) WithOnSuccess(
  fn func(totalAttempts int),
) *RetryCallbacks
```
Устанавливает коллбэк для успеха.

```go
func (rc *RetryCallbacks) WithOnFailure(
  fn func(
    totalAttempts int, 
    finalErr error, 
    reason string,
  ),
) *RetryCallbacks
```
Устанавливает коллбэк для ошибки.


## Константы ошибок AWS

### Ограничения

| Константа | Значение |
|-----------|----------|
| `Error429TooManyRequests` | "TooManyRequests" |
| `ErrorThrottling` | "Throttling" |
| `ErrorThrottlingException` | "ThrottlingException" |
| `ErrorThrottledException` | "ThrottledException" |
| `ErrorRequestThrottled` | "RequestThrottledException" |
| `ErrorRequestThrottledException` | "RequestThrottledException" |
| `ErrorTooManyRequestsException` | "TooManyRequestsException" |
| `ErrorEC2ThrottledException` | "EC2ThrottledException" |
| `ErrorSlowDown` | "SlowDown" |

### Превышение пропускной способности
| Константа | Значение |
|-----------|----------|
| `ErrorProvisionedThroughputExceededException` | "ProvisionedThroughputExceededException" |
| `ErrorRequestLimitExceeded` | "RequestLimitExceeded" |
| `ErrorBandwidthLimitExceeded` | "BandwidthLimitExceeded" |
| `ErrorLimitExceededException` | "LimitExceededException" |


### Недоступность сервиса
| Константа | Значение |
|-----------|----------|
| `ErrorServiceUnavailable` | "ServiceUnavailable" |
| `ErrorInternalServerError` | "InternalServerError" |
| `ErrorInternalError` | "InternalError" |
| `ErrorTemporaryFailure` | "TemporaryFailure" |

### Проблемы соединения

| Константа | Значение |
|-----------|----------|
| `ErrorRequestTimeout` | "RequestTimeout" |
| `ErrorRequestTimeoutException` | "RequestTimeoutException" |
| `ErrorConnectionError` | "ConnectionError" |
| `ErrorHTTPClientError` | "HTTPClientError" |

### Конфликты транзакций
| Константа | Значение |
|-----------|----------|
| `ErrorTransactionInProgressException` | "TransactionInProgressException" |
| `ErrorPriorRequestNotComplete` | "PriorRequestNotComplete" |

### Клиентские ошибки
| Константа | Значение |
|-----------|----------|
| `ErrorClientException` | "ClientException" |

## Предопределенные наборы ошибок

### RateLimitErrors

| Набор | Описание | Включает |
|-------|----------|----------|
| `RateLimitErrors` | Только ограничения скорости и троттлинг | TooManyRequests, Throttling, ThrottlingException, ThrottledException, RequestThrottledException, TooManyRequestsException, EC2ThrottledException, SlowDown |
| `ThroughputErrors` | Превышение пропускной способности | ProvisionedThroughputExceededException, RequestLimitExceeded, BandwidthLimitExceeded, LimitExceededException |
| `ServiceErrors` | Недоступность сервиса | ServiceUnavailable, InternalServerError, InternalError, TemporaryFailure |
| `ConnectionErrors` | Проблемы соединения и таймауты | RequestTimeout, RequestTimeoutException, ConnectionError, HTTPClientError |
| `TransactionErrors` | Конфликты транзакций | TransactionInProgressException, PriorRequestNotComplete |
| `TemporaryErrors` | Все временные ошибки | Объединение всех вышеперечисленных наборов |
| `ConservativeErrors` | Самые безопасные для повтора | TooManyRequests, Throttling, ThrottlingException, ServiceUnavailable, InternalServerError |
| `AggressiveErrors` | Все ошибки включая клиентские | TemporaryErrors + ClientException |


## Алиасы наборов ошибок

### Общие
| Алиас | Ссылается на | Описание |
|-------|--------------|----------|
| DefaultRetryableErrors | TemporaryErrors | Рекомендуемый по умолчанию |
| StrictRetryableErrors | ConservativeErrors | Минимальный безопасный набор |
| ThrottleOnlyErrors | RateLimitErrors | Только троттлинг |

### Для конкретных сервисов AWS

| Алиас | Состав | Описание |
|-------|--------|----------|
| `DynamoDBErrors` | RateLimitErrors + ThroughputErrors | Оптимизирован для DynamoDB |
| `KinesisErrors` | RateLimitErrors + ThroughputErrors | Оптимизирован для Kinesis |
| `S3Errors` | [SlowDown] + ServiceErrors | Оптимизирован для S3 |

## Mock (для тестирования)

### mock.Operation
```go
type Operation struct {
  CallCount int     // Счетчик вызовов Execute
  Errors    []error // Ошибки для возврата по порядку
  Result    any     // Результат при успехе
}
```
Имитирует AWS операцию для тестов.

```go
func (m *Operation) Execute(_ context.Context) (any, error)
```
Выполняет имитацию операции, возвращая ошибки по порядку или результат.

### mock.AWSError
```go
type AWSError struct {
  Code    string // Код ошибки AWS
  Message string // Сообщение ошибки
}
```
Имитирует ошибку AWS с кодом и сообщением.

```go
func (e *AWSError) Error() string
func (e *AWSError) ErrorCode() string
func (e *AWSError) ErrorMessage() string
func (e *AWSError) ErrorFault() smithy.ErrorFault

func NewAWSError(code, message string) error
```
Создает новую ошибку AWS с указанным кодом и сообщением.

### mock.Callbacks
```go
type Callbacks struct {
  RetryCalls   int // Количество вызовов OnRetry
  SuccessCalls int // Количество вызовов OnSuccess
  FailureCalls int // Количество вызовов OnFailure
   
  // Параметры последних вызовов
  LastRetryAttempt    int
  LastRetryError      error
  LastRetryDelay      time.Duration
  LastRetryErrorCode  string
  LastSuccessAttempts int
  LastFailureAttempts int
  LastFailureError    error
  LastFailureReason   string
   
  // История всех вызовов
  RetryHistory   []RetryCall
  SuccessHistory []SuccessCall
  FailureHistory []FailureCall
}
```
Имитирует коллбэки для проверки в тестах.

```go
func NewMockCallbacks() *Callbacks
```
Создает новые mock коллбэки.

```go
func (m *Callbacks) OnRetry(attempt int, err error, delay time.Duration, errorCode string)
func (m *Callbacks) OnSuccess(totalAttempts int)
func (m *Callbacks) OnFailure(totalAttempts int, finalErr error, reason string)
```
Имитируют соответствующие коллбэки и сохраняют параметры.

```go
func (m *Callbacks) Reset()
```
Сбрасывает все счетчики и историю.

```go
func (m *Callbacks) GetRetryCallCount() int
func (m *Callbacks) GetSuccessCallCount() int
func (m *Callbacks) GetFailureCallCount() int
```
Возвращают количество вызовов каждого типа коллбэка.

```go
func (m *Callbacks) GetRetryCall(index int) *RetryCall
func (m *Callbacks) GetSuccessCall(index int) *SuccessCall
func (m *Callbacks) GetFailureCall(index int) *FailureCall
```
Возвращают конкретный вызов коллбэка по индексу.

### Типы истории вызовов
```go
type RetryCall struct {
  Attempt   int
  Error     error
  Delay     time.Duration
  ErrorCode string
}

type SuccessCall struct {
   TotalAttempts int
}

type FailureCall struct {
  TotalAttempts int
  FinalError    error
  Reason        string
}
```