# BitSocial Protocol

A privacy-first decentralized social networking protocol built on Bitcoin's Stacks Layer 2, designed for authentic social connections with complete user control over data and privacy.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Contract Architecture](#contract-architecture)
- [Data Flow](#data-flow)
- [Getting Started](#getting-started)
- [Core Functions](#core-functions)
- [Privacy & Security](#privacy--security)
- [Rate Limiting & Anti-Spam](#rate-limiting--anti-spam)
- [Technical Specifications](#technical-specifications)
- [Development](#development)

## Overview

BitSocial is a Bitcoin-native social platform that prioritizes user privacy, data ownership, and authentic social connections. Built on Stacks Layer 2, it leverages Bitcoin's security while providing the scalability needed for social interactions.

The protocol features intelligent rate limiting, batch optimization, granular privacy controls, and comprehensive user safety mechanisms, creating a secure and efficient social networking environment.

## Key Features

### Core Functionality

- **Privacy-First Design**: Optional end-to-end encryption and granular privacy controls
- **Decentralized Identity**: User-controlled profiles and data ownership
- **Social Graph Management**: Friend requests, connections, and relationship tracking
- **Content Management**: Posts, messages, and content moderation
- **User Safety**: Multi-layered blocking and reporting mechanisms

### Performance & Security

- **Intelligent Batch Processing**: Automatic optimization for transaction efficiency
- **Advanced Rate Limiting**: Anti-spam protection with adaptive thresholds
- **Reputation System**: Dynamic trust scoring based on user behavior
- **Activity Analytics**: Comprehensive engagement tracking and insights

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    BitSocial Protocol                       │
├─────────────────────────────────────────────────────────────┤
│                   Stacks Layer 2                            │
├─────────────────────────────────────────────────────────────┤
│                   Bitcoin Blockchain                        │
└─────────────────────────────────────────────────────────────┘

Components:
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ User Manager │  │ Social Graph │  │ Privacy      │
│              │  │              │  │ Controls     │
├──────────────┤  ├──────────────┤  ├──────────────┤
│ Rate Limiter │  │ Content Mgmt │  │ Batch        │
│              │  │              │  │ Optimizer    │
├──────────────┤  ├──────────────┤  ├──────────────┤
│ Analytics    │  │ Safety       │  │ Reputation   │
│              │  │ System       │  │ Engine       │
└──────────────┘  └──────────────┘  └──────────────┘
```

## Contract Architecture

### Data Storage Maps

#### Core User Data

- **Users**: Primary user registry with identity and profile information
- **UserPrivacy**: Granular privacy settings and visibility controls
- **UserActivity**: Comprehensive activity tracking and engagement metrics
- **UserBatches**: Intelligent batch processing optimization data

#### Social Relationships

- **Friendships**: Bilateral relationship management with interaction history
- **BlockedUsers**: Multi-layered safety infrastructure with reporting
- **UserContent**: Content management with moderation status

#### Security & Performance

- **RateLimits**: Advanced anti-spam protection with violation tracking
- **PlatformConfig**: Administrative controls and system configuration

### Status Constants

#### User Account Status

- `STATUS_ACTIVE` (1): Standard active user
- `STATUS_PREMIUM` (3): Enhanced features access
- `STATUS_SUSPENDED` (2): Temporarily restricted
- `STATUS_DEACTIVATED` (0): Account disabled

#### Relationship Status

- `FRIENDSHIP_ACTIVE` (1): Confirmed friendship
- `FRIENDSHIP_PENDING` (0): Awaiting acceptance
- `FRIENDSHIP_BLOCKED` (2): Blocked relationship
- `FRIENDSHIP_DECLINED` (3): Rejected request

## Data Flow

### User Registration Flow

```
User Request → Validation → Profile Creation → Privacy Setup → Activity Init
     ↓              ↓             ↓              ↓             ↓
Input Check → Name Length → User Map Entry → Privacy Map → Rate Limits
```

### Friend Request Flow

```
Request → Validation → Rate Check → Block Check → Create Pending → Notify
   ↓         ↓           ↓           ↓            ↓            ↓
Sender → Target Exists → Not Spam → Not Blocked → Friendship → Event
```

### Privacy Update Flow

```
Settings → Authentication → Rate Limit → Validation → Update → Analytics
   ↓           ↓              ↓           ↓          ↓        ↓
Request → Active User → Check Limits → Valid Data → Store → Track
```

### Batch Optimization Flow

```
Activity → Analysis → Optimization → Size Adjustment → Efficiency Update
    ↓         ↓           ↓              ↓               ↓
Usage → Pattern → Algorithm → New Batch Size → Performance
```

## Getting Started

### Prerequisites

- Stacks CLI installed
- Bitcoin testnet/mainnet access
- Clarity development environment

### Deployment

1. **Clone and Setup**

```bash
git clone <repository-url>
cd bitsocial-protocol
```

2. **Deploy Contract**

```bash
stx deploy bitsocial.clar --network <testnet|mainnet>
```

3. **Initialize Platform**

```clarity
(contract-call? .bitsocial get-platform-stats)
```

## Core Functions

### User Management

#### Registration

```clarity
(register-user "username" (some "metadata") true)
```

#### Profile Updates

```clarity
(update-user-profile 
  (some "new-name") 
  (some "updated-metadata") 
  none 
  (some "profile-image-url"))
```

### Social Connections

#### Send Friend Request

```clarity
(send-friend-request 'SP1ABCD...)
```

#### Accept Request

```clarity
(accept-friend-request 'SP1ABCD...)
```

#### Block User

```clarity
(block-user 'SP1ABCD... (some "reason"))
```

### Privacy Controls

#### Update Privacy Settings

```clarity
(update-advanced-privacy-settings 
  true   ;; friend-list-visible
  true   ;; status-visible
  false  ;; metadata-visible
  false  ;; last-seen-visible
  true   ;; profile-image-visible
  true   ;; encryption-enabled
  true   ;; analytics-enabled
  false) ;; public-profile
```

### Read-Only Queries

#### Get User Profile

```clarity
(get-user-profile 'SP1ABCD...)
```

#### Check Friendship Status

```clarity
(check-friendship-status 'SP1USER1... 'SP1USER2...)
```

## Privacy & Security

### Encryption Support

- Optional end-to-end encryption for sensitive data
- User-controlled encryption keys
- Secure metadata handling

### Privacy Granularity

- Individual setting controls for each data type
- Public/private profile options
- Selective visibility for friends vs. public

### Safety Mechanisms

- Multi-layered user blocking system
- Comprehensive reporting infrastructure
- Automatic spam detection and prevention

## Rate Limiting & Anti-Spam

### Daily Limits

- **Actions**: 150 per day
- **Friend Requests**: 25 per day
- **Status Updates**: 50 per day
- **Messages**: 200 per day

### Intelligent Features

- Automatic limit reset every 24 hours
- Violation tracking and escalation
- Adaptive batch sizing for performance optimization

### Batch Processing

- Minimum batch size: 5 operations
- Maximum batch size: 100 operations
- Automatic optimization based on usage patterns
- 1-hour expiry for inactive batches

## Technical Specifications

### Platform Limits

- **Name Length**: 64 characters maximum
- **Metadata**: 512 characters maximum
- **Messages**: 280 characters (Twitter-like)
- **Batch Expiry**: 3600 seconds (1 hour)

### Performance Metrics

- Reputation scoring based on engagement
- Activity streak tracking
- Optimization efficiency monitoring
- Processing performance analytics

### Error Handling

Comprehensive error system with specific codes:

- `ERR_NOT_FOUND` (100): Resource not found
- `ERR_UNAUTHORIZED` (102): Access denied
- `ERR_RATE_LIMITED` (106): Too many requests
- `ERR_BLOCKED` (104): User blocked interaction

## Development

### Testing

```bash
# Run unit tests
stx test

# Integration testing
stx test --integration
```

### Local Development

```bash
# Start local devnet
stx devnet start

# Deploy to local network
stx deploy --network devnet
```

### Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## Network Information

- **Version**: 1.0.0
- **Network**: Stacks Mainnet/Testnet
- **Language**: Clarity Smart Contract Language
- **Dependencies**: Stacks Blockchain, Bitcoin Network
