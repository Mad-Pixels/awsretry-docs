# Reference

## Main Functions

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
Creates a custom retry configuration.

### DefaultRetryConfig
```go
func DefaultRetryConfig() RetryConfig
```
Creates a default retry configuration:
- Maximum of 3 retries
- Initial delay of 100ms
- Maximum delay of 1s
- Backoff multiplier of 1.5
- Retries on RateLimitErrors

### ExecuteWithRetry
```go
func ExecuteWithRetry[T any](
  ctx context.Context,
  operation func(ctx context.Context) (T, error),
  config RetryConfig,
  callbacks *RetryCallbacks,
) (T, error)
```
Executes the operation with retries on AWS errors.

### NewRetryCallbacks
```go
func NewRetryCallbacks() *RetryCallbacks
```
Creates empty callbacks for tracking retry events.

## Типы

### RetryConfig

```go
type RetryConfig struct {
  MaxRetries      int           // Maximum number of retries after the initial attempt
  BaseDelay       time.Duration // Initial delay before retrying
  MaxDelay        time.Duration // Maximum delay between retries
  Multiplier      float64       // Multiplier for exponential backoff
  RetryableErrors []string      // AWS error codes to trigger a retry
}
```

### RetryCallbacks
```go
type RetryCallbacks struct {
  OnRetry   func(attempt int, err error, delay time.Duration, errorCode string)  // Called before each retry
  OnSuccess func(totalAttempts int)                                              // Called on successful execution
  OnFailure func(totalAttempts int, finalErr error, reason string)               // Called on failure after all retries
}
```

#### RetryCallbacks Methods
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
Sets the callback for retries.

```go
func (rc *RetryCallbacks) WithOnSuccess(
  fn func(totalAttempts int),
) *RetryCallbacks
```
Sets the callback for success.

```go
func (rc *RetryCallbacks) WithOnFailure(
  fn func(
    totalAttempts int, 
    finalErr error, 
    reason string,
  ),
) *RetryCallbacks
```
Sets the callback for failure.


## AWS Error Constants

### Throttling
| Constant | Value |
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

### Throughput exceeded
| Constant | Value |
|-----------|----------|
| `ErrorProvisionedThroughputExceededException` | "ProvisionedThroughputExceededException" |
| `ErrorRequestLimitExceeded` | "RequestLimitExceeded" |
| `ErrorBandwidthLimitExceeded` | "BandwidthLimitExceeded" |
| `ErrorLimitExceededException` | "LimitExceededException" |


### Service unavailable
| Constant | Value |
|-----------|----------|
| `ErrorServiceUnavailable` | "ServiceUnavailable" |
| `ErrorInternalServerError` | "InternalServerError" |
| `ErrorInternalError` | "InternalError" |
| `ErrorTemporaryFailure` | "TemporaryFailure" |

### Connection issues
| Constant | Value |
|-----------|----------|
| `ErrorRequestTimeout` | "RequestTimeout" |
| `ErrorRequestTimeoutException` | "RequestTimeoutException" |
| `ErrorConnectionError` | "ConnectionError" |
| `ErrorHTTPClientError` | "HTTPClientError" |

### Transaction conflicts
| Constant | Value |
|-----------|----------|
| `ErrorTransactionInProgressException` | "TransactionInProgressException" |
| `ErrorPriorRequestNotComplete` | "PriorRequestNotComplete" |

### Client errors
| Constant | Value |
|-----------|----------|
| `ErrorClientException` | "ClientException" |

## Predefined error sets

### RateLimitErrors
| Set                  | Description                              | Includes                                                                                                           |
|----------------------|------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| `RateLimitErrors`    | Only rate limits and throttling          | TooManyRequests, Throttling, ThrottlingException, ThrottledException, RequestThrottledException, TooManyRequestsException, EC2ThrottledException, SlowDown |
| `ThroughputErrors`   | Throughput exceeded                      | ProvisionedThroughputExceededException, RequestLimitExceeded, BandwidthLimitExceeded, LimitExceededException     |
| `ServiceErrors`      | Service unavailable                      | ServiceUnavailable, InternalServerError, InternalError, TemporaryFailure                                          |
| `ConnectionErrors`   | Connection issues and timeouts           | RequestTimeout, RequestTimeoutException, ConnectionError, HTTPClientError                                         |
| `TransactionErrors`  | Transaction conflicts                    | TransactionInProgressException, PriorRequestNotComplete                                                           |
| `TemporaryErrors`    | All temporary errors                     | Union of all the above sets                                                                                       |
| `ConservativeErrors` | Safest errors to retry                   | TooManyRequests, Throttling, ThrottlingException, ServiceUnavailable, InternalServerError                         |
| `AggressiveErrors`   | All errors including client-side errors | TemporaryErrors + ClientException                                                                                 |

## Error Set Aliases

### General

| Alias                  | Refers to           | Description                      |
|------------------------|---------------------|----------------------------------|
| `DefaultRetryableErrors` | `TemporaryErrors`     | Recommended default              |
| `StrictRetryableErrors`  | `ConservativeErrors`  | Minimal safe set                 |
| `ThrottleOnlyErrors`     | `RateLimitErrors`     | Throttling only                  |

### For Specific AWS Services

| Alias           | Composition                                 | Description               |
|-----------------|---------------------------------------------|---------------------------|
| `DynamoDBErrors` | RateLimitErrors + ThroughputErrors          | Optimized for DynamoDB    |
| `KinesisErrors`  | RateLimitErrors + ThroughputErrors          | Optimized for Kinesis     |
| `S3Errors`       | [SlowDown] + ServiceErrors                  | Optimized for S3          |

## Mock (for testing)

### mock.Operation
```go
type Operation struct {
  CallCount int     // Counter of Execute calls
  Errors    []error // Errors to return in sequence
  Result    any     // Result to return on success
}
```
Simulates an AWS operation for testing.

```go
func (m *Operation) Execute(_ context.Context) (any, error)
```
Executes the mock operation, returning errors in sequence or the result.

### mock.AWSError
```go
type AWSError struct {
  Code    string // AWS error code
  Message string // Error message
}
```
Simulates an AWS error with a code and message.

```go
func (e *AWSError) Error() string
func (e *AWSError) ErrorCode() string
func (e *AWSError) ErrorMessage() string
func (e *AWSError) ErrorFault() smithy.ErrorFault

func NewAWSError(code, message string) error
```
Creates a new AWS error with the specified code and message.

### mock.Callbacks
```go
type Callbacks struct {
  RetryCalls   int // Number of OnRetry calls
  SuccessCalls int // Number of OnSuccess calls
  FailureCalls int // Number of OnFailure calls

  // Parameters of the last calls
  LastRetryAttempt    int
  LastRetryError      error
  LastRetryDelay      time.Duration
  LastRetryErrorCode  string
  LastSuccessAttempts int
  LastFailureAttempts int
  LastFailureError    error
  LastFailureReason   string

  // History of all calls
  RetryHistory   []RetryCall
  SuccessHistory []SuccessCall
  FailureHistory []FailureCall
}
```
Simulates callbacks for verification in tests.

```go
func NewMockCallbacks() *Callbacks
```
Creates new mock callbacks.

```go
func (m *Callbacks) OnRetry(attempt int, err error, delay time.Duration, errorCode string)
func (m *Callbacks) OnSuccess(totalAttempts int)
func (m *Callbacks) OnFailure(totalAttempts int, finalErr error, reason string)
```
Simulates the corresponding callbacks and records parameters.

```go
func (m *Callbacks) Reset()
```
Resets all counters and history.

```go
func (m *Callbacks) GetRetryCallCount() int
func (m *Callbacks) GetSuccessCallCount() int
func (m *Callbacks) GetFailureCallCount() int
```
Returns the number of calls for each callback type.

```go
func (m *Callbacks) GetRetryCall(index int) *RetryCall
func (m *Callbacks) GetSuccessCall(index int) *SuccessCall
func (m *Callbacks) GetFailureCall(index int) *FailureCall
```
Returns a specific callback invocation by index.

### Types of callback invocation history
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