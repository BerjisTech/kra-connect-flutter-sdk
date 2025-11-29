# Changelog

All notable changes to the KRA Connect Flutter SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [0.1.0] - 2025-01-28

### Added

#### Core Features
- PIN verification with comprehensive result data
- TCC (Tax Compliance Certificate) verification
- E-slip validation with payment status tracking
- NIL return filing functionality
- Taxpayer details retrieval with obligations tracking

#### Batch Operations
- Batch PIN verification for processing multiple PINs concurrently
- Batch TCC verification for multiple certificates
- Batch e-slip validation for multiple payment slips

#### Client Features
- Configurable HTTP client with retry logic
- Automatic retry with exponential backoff and jitter
- Response caching with TTL (Time-To-Live)
- Rate limiting using token bucket algorithm
- Request timeout handling
- Custom headers support

#### Data Models
- `PinVerificationResult` - PIN verification response with helper methods
- `TccVerificationResult` - TCC verification response with expiry checking
- `EslipValidationResult` - E-slip validation response with payment status
- `NilReturnRequest` - NIL return filing request DTO
- `NilReturnResult` - NIL return filing response
- `TaxpayerDetails` - Comprehensive taxpayer information
- `TaxObligation` - Tax obligation details with due date calculations

#### Exception Handling
- `KraException` - Base sealed exception class
- `ValidationException` - Input validation errors
- `AuthenticationException` - API authentication failures
- `RateLimitException` - Rate limit exceeded errors
- `TimeoutException` - Request timeout errors
- `ApiException` - General API errors
- `NetworkException` - Network connectivity errors
- `CacheException` - Cache operation errors

#### Utilities
- Comprehensive input validators for PIN, TCC, e-slip, dates, emails, phones
- Amount validation with range checking
- Tax period validation
- API key validation

#### Services
- `CacheManager` - LRU cache with TTL and pattern-based removal
- `RateLimiter` - Token bucket rate limiter with configurable limits
- `RetryHandler` - Exponential backoff retry logic with jitter
- `HttpClient` - Full-featured HTTP client with authentication

#### Configuration
- Flexible `KraConfig` with sensible defaults
- Configurable timeouts, retries, and delays
- Cache size and TTL configuration
- Rate limit configuration
- Debug logging support
- Custom headers support
- User agent customization

#### Developer Experience
- Full Dart null safety support
- Comprehensive inline documentation
- Type-safe API throughout
- Helper methods on all result types
- Builder pattern for configuration
- Async/await API

#### Testing
- Unit tests for models with JSON serialization
- Unit tests for validators covering all edge cases
- Unit tests for cache manager with expiry testing
- Integration tests with mocked HTTP responses
- 80%+ test coverage

#### Examples
- Basic usage example with all core features
- Batch operations example with error handling
- Flutter widget example with state management
- Supplier verification workflow example
- Cache and rate limiter statistics examples

#### Documentation
- Comprehensive README with usage examples
- API reference documentation
- Error handling guide
- Flutter widget integration examples
- Stream pattern examples
- FutureBuilder pattern examples

### Dependencies
- `http: ^1.1.0` - HTTP client
- `meta: ^1.10.0` - Metadata annotations for Dart 3.0+ sealed classes

### Requirements
- Dart 3.0 or higher
- Flutter 3.10 or higher

### Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## [Unreleased]

### Planned Features
- Stream-based real-time updates
- Offline mode with request queuing
- Background sync support
- Certificate pinning for enhanced security
- Request/response interceptors
- Webhook signature validation
- File attachment support for NIL returns
- Bulk operations with progress tracking
- Advanced caching strategies (Redis, Hive)
- Metric collection and monitoring
- Request cancellation support
- Connection pooling optimization
- GraphQL support (if API provides it)

---

[0.1.0]: https://github.com/kra-connect/flutter-sdk/releases/tag/v0.1.0
