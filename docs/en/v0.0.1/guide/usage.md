# Usage
A complete guide to using the `awsretry` library for handling AWS operation retries.

## Installation

```bash
go get github.com/Mad-Pixels/awsretry@v0.0.1
```
::: tip Требования
Minimum Go version: 1.24+
:::

## Quick Start
### Basic Usage
```go
func main() {
  // Simple retry with default settings
  result, err := awsretry.ExecuteWithRetry(ctx,
    func(ctx context.Context) (*dynamodb.GetItemOutput, error) {
      return client.GetItem(ctx, input)
    },
    awsretry.DefaultRetryConfig(),
    nil, // no callbacks
  )
  if err != nil {
    log.Fatal(err)
  }
   
  fmt.Println("Success:", result)
}
```
::: info What's happening?
- Up to 3 retries after the first attempt
- Initial delay of 100ms with a multiplier of 1.5
- Only rate limit errors are retried
- No logging enabled
:::

## Configuration
### Default Settings
```go
config := awsretry.DefaultRetryConfig()
// MaxRetries: 3
// BaseDelay: 100ms  
// MaxDelay: 1s
// Multiplier: 1.5
// RetryableErrors: RateLimitErrors
```

### Custom Configuration
::: code-group
```go [Aggressive]
config := awsretry.NewRetryConfig(
  5,                           // up to 5 retries
  200*time.Millisecond,        // start with 200ms delay
  5*time.Second,               // max delay of 5s
  2.0,                         // double the delay each time
  awsretry.TemporaryErrors,    // all temporary errors
)
```

```go [Conservative]
config := awsretry.NewRetryConfig(
  2,                           // total of 2 retries
  500*time.Millisecond,        // start with 500ms delay
  2*time.Second,               // max delay of 2s
  1.2,                         // slow backoff growth
  awsretry.ConservativeErrors, // only safe retryable errors
)
```

```go [DynamoDB]
config := awsretry.NewRetryConfig(
  4,                           // up to 4 retries
  100*time.Millisecond,        // start with 100ms delay
  time.Second,                 // max delay of 1s
  1.5,                         // exponential backoff multiplier
  awsretry.DynamoDBErrors,     // DynamoDB-specific errors
)
```
:::

## Logging and Monitoring
### Simple Logging
```go
callbacks := awsretry.NewRetryCallbacks().
  WithOnRetry(
    func(
      attempt int, 
      err error, 
      delay time.Duration, 
      errorCode string,
    ) {
      log.Printf("Attempt %d: %s (delay: %v, code: %s)", attempt, err, delay, errorCode)
  })

result, err := awsretry.ExecuteWithRetry(ctx, operation, config, callbacks)
```

### Full Logging
```go
callbacks := awsretry.NewRetryCallbacks().
  WithOnRetry(
    func(
      attempt int, 
      err error, 
      delay time.Duration, 
      errorCode string,
    ) {
      log.Printf("🔄 Retry %d: %s (delay: %v, code: %s)", attempt, err, delay, errorCode)
    },
  ).
  WithOnSuccess(
    func(totalAttempts int) {
      log.Printf("✅ Success after %d attempt(s)", totalAttempts)
    },
  ).
  WithOnFailure(
    func(
      totalAttempts int, 
      finalErr error, 
      reason string,
    ) {
      log.Printf("❌ Failure after %d attempt(s): %s (%s)", totalAttempts, finalErr, reason)
    },
  )
```

### Integration with Loggers
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

## Choosing Retryable Errors
### Predefined Sets
::: tip Recommendations
- **TemporaryErrors** - suitable for most cases
- **ConservativeErrors** - best for critical operations
- **DynamoDBErrors** - optimized for DynamoDB operations
- **S3Errors** - optimized for S3 operations
:::

::: code-group

```go [All temporary errors]
config := awsretry.NewRetryConfig(
  3, 
  100*time.Millisecond, 
  time.Second, 1.5, 
  awsretry.TemporaryErrors,
) // Recommended
```

```go [Throttling only]
config := awsretry.NewRetryConfig(
  5, 
  50*time.Millisecond, 
  500*time.Millisecond, 
  2.0,
  awsretry.RateLimitErrors,
) // Throttling only
```

```go [Custom Set]
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

## Examples for Different AWS Services
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

## Advanced Scenarios
### Context

::: code-group
```go [With Timeout]
// The operation will be aborted after 30 seconds
ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()

result, err := awsretry.ExecuteWithRetry(ctx, operation, config, callbacks)
if errors.Is(err, context.DeadlineExceeded) {
   log.Println("Operation aborted due to timeout")
}
```

```go [With Cancel]
ctx, cancel := context.WithCancel(context.Background())

// In another goroutine
go func() {
  time.Sleep(5 * time.Second)
  cancel() // Cancel the operation
}()

result, err := awsretry.ExecuteWithRetry(ctx, operation, config, callbacks)
if errors.Is(err, context.Canceled) {
  log.Println("Operation canceled")
}
```
:::

### Conditional Retries
```go
// Retry only specific errors
customConfig := awsretry.NewRetryConfig(
  3, 
  100*time.Millisecond, 
  time.Second, 
  1.5, 
  []string{"SpecificError", "AnotherError"}),
)

// Or wrap logic in a custom function
func retryWithCondition(ctx context.Context, operation func(ctx context.Context) (string, error)) (string, error) {
  return awsretry.ExecuteWithRetry(ctx,
    func(ctx context.Context) (string, error) {
      result, err := operation(ctx)
      if err != nil {
        // Additional check
        if strings.Contains(err.Error(), "temporary") {
          return "", err // Retry
        }
        // Convert to a non-retryable error
        return "", fmt.Errorf("permanent error: %w", err)
      }
      return result, nil
    }, customConfig, nil)
}
```

### Metrics and Monitoring
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

// Usage
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

## Best Practices

### ✅ Do

::: tip Recommendations
- Use `TemporaryErrors` for most cases
- Set a reasonable `MaxDelay` (1-10 seconds)
- Log retries for debugging purposes
- Respect context timeouts
- Test retry behavior thoroughly
:::

### ❌ Avoid

::: danger Don't do this
- Don't set too many retries (>10)
- Don't ignore cancellation context
- Don't retry non-recoverable errors
- Don't forget to set a MaxDelay
- Don't use retries for validation errors
:::

## Understanding Delays
### Exponential Backoff
Formula: `delay = BaseDelay × (Multiplier ^ attempt)`
::: details Calculation Example
With BaseDelay=100ms, Multiplier=1.5:
- Attempt 1: 100ms × 1.5⁰ = 100ms
- Attempt 2: 100ms × 1.5¹ = 150ms  
- Attempt 3: 100ms × 1.5² = 225ms
- Attempt 4: 100ms × 1.5³ = 337ms
:::
