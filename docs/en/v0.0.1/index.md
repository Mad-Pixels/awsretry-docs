---
layout: home

hero:
  name: "AWS-Retry"
  text: "Go library for AWS API retries"
  actions:
    - theme: brand
      text: Usage 
      link: ./guide/usage
    - theme: brand
      text: Reference
      link: ./reference/lib
    - theme: alt
      text: Releases
      link: https://github.com/Mad-Pixels/awsretry/releases
    - theme: alt
      text: Source
      link: https://github.com/Mad-Pixels/awsretry
  image: /logo.png

features:
 - title: Zero Dependencies
   details: Clean implementation using only Go standard library and smithy-go with no external dependencies
 - title: Flexible Callbacks
   details: Integrate with any logging framework through configurable callback system for retry events
 - title: Comprehensive Error Coverage
   details: Pre-defined error sets optimized for DynamoDB, S3, Kinesis and all AWS services
 - title: Smart Exponential Backoff
   details: Configurable retry strategies with exponential backoff
---