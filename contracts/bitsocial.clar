;; BitSocial Protocol
;; Title: BitSocial - Decentralized Social Networking Protocol
;; Summary: A Bitcoin-native social platform built on Stacks Layer 2 with privacy-first architecture
;; Description: BitSocial enables users to build authentic social connections while maintaining
;;              full control over their data and privacy. Features include intelligent rate limiting,
;;              batch optimization, granular privacy controls, and comprehensive user safety mechanisms.
;;              Built for the Bitcoin ecosystem with Stacks Layer 2 scalability.
;;
;; Key Features:
;; - Privacy-first design with optional end-to-end encryption
;; - Intelligent batch processing for optimal performance
;; - Advanced anti-spam and rate limiting protection
;; - Comprehensive social graph management
;; - Built-in analytics and user activity tracking
;; - Multi-layered user safety and blocking mechanisms


;; ERROR CONSTANTS - Standardized Error Handling System

(define-constant ERR_NOT_FOUND (err u100))
(define-constant ERR_ALREADY_EXISTS (err u101))
(define-constant ERR_UNAUTHORIZED (err u102))
(define-constant ERR_INVALID_INPUT (err u103))
(define-constant ERR_BLOCKED (err u104))
(define-constant ERR_DEACTIVATED (err u105))
(define-constant ERR_RATE_LIMITED (err u106))
(define-constant ERR_BATCH_FULL (err u107))
(define-constant ERR_BATCH_EXPIRED (err u108))
(define-constant ERR_INSUFFICIENT_BALANCE (err u109))
(define-constant ERR_CONTRACT_PAUSED (err u110))

;; STATUS CONSTANTS - Platform State Management

;; User Account Status Definitions
(define-constant STATUS_DEACTIVATED u0)
(define-constant STATUS_ACTIVE u1)
(define-constant STATUS_SUSPENDED u2)
(define-constant STATUS_PREMIUM u3)

;; Relationship Status Definitions
(define-constant FRIENDSHIP_PENDING u0)
(define-constant FRIENDSHIP_ACTIVE u1)
(define-constant FRIENDSHIP_BLOCKED u2)
(define-constant FRIENDSHIP_DECLINED u3)

;; Content Moderation Status
(define-constant CONTENT_APPROVED u0)
(define-constant CONTENT_FLAGGED u1)
(define-constant CONTENT_REMOVED u2)

;; PLATFORM LIMITS - Spam Protection & Resource Management

;; Daily Action Limits for Platform Stability
(define-constant MAX_ACTIONS_PER_DAY u150)
(define-constant MAX_FRIEND_REQUESTS_PER_DAY u25)
(define-constant MAX_STATUS_UPDATES_PER_DAY u50)
(define-constant MAX_MESSAGES_PER_DAY u200)
(define-constant RATE_LIMIT_RESET_PERIOD u86400) ;; 24 hours in seconds

;; Batch Processing Configuration
(define-constant MIN_BATCH_SIZE u5)
(define-constant MAX_BATCH_SIZE u100)
(define-constant BATCH_EXPIRY_PERIOD u3600) ;; 1 hour in seconds
(define-constant OPTIMAL_BATCH_THRESHOLD u75) ;; 75% capacity trigger

;; Content Limits
(define-constant MAX_NAME_LENGTH u64)
(define-constant MAX_METADATA_LENGTH u512)
(define-constant MAX_MESSAGE_LENGTH u280) ;; Twitter-like limit

;; DATA STORAGE MAPS - Core Platform State

;; Primary User Registry - Core Identity Management
(define-map Users
  principal
  {
    name: (string-ascii 64),
    status: uint,
    timestamp: uint,
    metadata: (optional (string-utf8 512)),
    deactivation-time: (optional uint),
    encryption-key: (optional (buff 32)),
    profile-image: (optional (string-utf8 256)),
    reputation-score: uint,
    verification-status: bool,
  }
)

;; Enhanced Privacy Control Center - Granular Visibility Settings
(define-map UserPrivacy
  principal
  {
    friend-list-visible: bool,
    status-visible: bool,
    metadata-visible: bool,
    last-seen-visible: bool,
    profile-image-visible: bool,
    encryption-enabled: bool,
    analytics-enabled: bool,
    public-profile: bool,
    last-updated: uint,
  }
)

;; Advanced Rate Limiting Engine - Anti-Spam Protection
(define-map RateLimits
  principal
  {
    daily-actions: uint,
    friend-requests: uint,
    status-updates: uint,
    messages-sent: uint,
    last-reset: uint,
    violation-count: uint,
  }
)

;; Intelligent Batch Processing Optimizer - Performance Enhancement
(define-map UserBatches
  principal
  {
    message-counter: uint,
    last-batch-timestamp: uint,
    batch-size: uint,
    current-batch-items: uint,
    total-batches: uint,
    optimization-score: uint,
    processing-efficiency: uint,
  }
)

;; Comprehensive Activity Analytics - User Engagement Tracking
(define-map UserActivity
  principal
  {
    last-seen: uint,
    login-count: uint,
    total-actions: uint,
    last-action: uint,
    streak-count: uint,
    engagement-score: uint,
  }
)

;; Enhanced Social Graph Management - Friendship Relations
(define-map Friendships
  {
    user1: principal,
    user2: principal,
  }
  { 
    status: uint,
    created-at: uint,
    last-interaction: uint,
    interaction-count: uint,
  }
)

;; Multi-layered Safety Infrastructure - User Blocking System
(define-map BlockedUsers
  {
    blocker: principal,
    blocked: principal,
  }
  { 
    timestamp: uint,
    reason: (optional (string-utf8 128)),
    report-count: uint,
  }
)

;; Content Management System - Post and Message Tracking
(define-map UserContent
  {
    author: principal,
    content-id: uint,
  }
  {
    content: (string-utf8 280),
    timestamp: uint,
    likes: uint,
    shares: uint,
    status: uint,
    encrypted: bool,
  }
)

;; Platform Configuration - Admin Controls
(define-map PlatformConfig
  (string-ascii 32)
  {
    value: uint,
    last-updated: uint,
    updated-by: principal,
  }
)

;; PRIVATE UTILITY FUNCTIONS - Internal Logic Components

;; Enhanced Rate Limit Validator - Automatic Reset & Advanced Validation
(define-private (check-rate-limit
    (user principal)
    (action-type uint)
  )
  (let (
      (rate-data (default-to {
        daily-actions: u0,
        friend-requests: u0,
        status-updates: u0,
        messages-sent: u0,
        last-reset: stacks-block-height,
        violation-count: u0,
      }
        (map-get? RateLimits user)
      ))
      (current-time stacks-block-height)
      (should-reset (> (- current-time (get last-reset rate-data)) RATE_LIMIT_RESET_PERIOD))
    )
    (if should-reset
      (begin
        (map-set RateLimits user {
          daily-actions: u1,
          friend-requests: (if (is-eq action-type u1) u1 u0),
          status-updates: (if (is-eq action-type u2) u1 u0),
          messages-sent: (if (is-eq action-type u3) u1 u0),
          last-reset: current-time,
          violation-count: u0,
        })
        true
      )
      (and
        (< (get daily-actions rate-data) MAX_ACTIONS_PER_DAY)
        (< (get violation-count rate-data) u5) ;; Max 5 violations per day
        (or (not (is-eq action-type u1)) (< (get friend-requests rate-data) MAX_FRIEND_REQUESTS_PER_DAY))
        (or (not (is-eq action-type u2)) (< (get status-updates rate-data) MAX_STATUS_UPDATES_PER_DAY))
        (or (not (is-eq action-type u3)) (< (get messages-sent rate-data) MAX_MESSAGES_PER_DAY))
      )
    )
  )
)

;; Enhanced Rate Limit Counter - Action Tracking & Intelligent Increment
(define-private (update-rate-limit
    (user principal)
    (action-type uint)
  )
  (let ((rate-data (unwrap-panic (map-get? RateLimits user))))
    (map-set RateLimits user
      (merge rate-data {
        daily-actions: (+ (get daily-actions rate-data) u1),
        friend-requests: (+ (get friend-requests rate-data) (if (is-eq action-type u1) u1 u0)),
        status-updates: (+ (get status-updates rate-data) (if (is-eq action-type u2) u1 u0)),
        messages-sent: (+ (get messages-sent rate-data) (if (is-eq action-type u3) u1 u0)),
      })
    )
  )
)

;; Advanced Activity Logger - Comprehensive User Action Tracking with Streaks
(define-private (update-user-activity (user principal))
  (let (
      (current-time stacks-block-height)
      (activity (default-to {
        last-seen: current-time,
        login-count: u0,
        total-actions: u0,
        last-action: current-time,
        streak-count: u0,
        engagement-score: u0,
      }
        (map-get? UserActivity user)
      ))
      (is-consecutive-day (< (- current-time (get last-action activity)) u86400))
    )
    (map-set UserActivity user
      (merge activity {
        last-seen: current-time,
        total-actions: (+ (get total-actions activity) u1),
        last-action: current-time,
        streak-count: (if is-consecutive-day (+ (get streak-count activity) u1) u1),
        engagement-score: (+ (get engagement-score activity) u1),
      })
    )
  )
)

;; Mathematical Utilities - Optimization Helpers
(define-private (max-uint (a uint) (b uint))
  (if (>= a b) a b)
)

(define-private (min-uint (a uint) (b uint))
  (if (<= a b) a b)
)

;; Enhanced Social Graph Validators - Relationship Verification with History
(define-private (are-friends (user1 principal) (user2 principal))
  (match (map-get? Friendships { user1: user1, user2: user2 })
    friendship (is-eq (get status friendship) FRIENDSHIP_ACTIVE)
    (match (map-get? Friendships { user1: user2, user2: user1 })
      friendship (is-eq (get status friendship) FRIENDSHIP_ACTIVE)
      false
    )
  )
)

;; Enhanced User Status Validators - Security & Access Control
(define-private (check-active-user (user principal))
  (match (map-get? Users user)
    user-data (and
      (or (is-eq (get status user-data) STATUS_ACTIVE) (is-eq (get status user-data) STATUS_PREMIUM))
      (is-none (get deactivation-time user-data))
    )
    false
  )
)

(define-private (user-exists (user principal))
  (is-some (map-get? Users user))
)

;; Enhanced Safety Validators - Blocking & Protection with Reporting
(define-private (is-blocked (blocker principal) (blocked principal))
  (or
    (is-some (map-get? BlockedUsers { blocker: blocker, blocked: blocked }))
    (is-some (map-get? BlockedUsers { blocker: blocked, blocked: blocker }))
  )
)

;; Enhanced Privacy Settings Accessor - Secure Default Configuration
(define-private (get-privacy-settings (user principal))
  (default-to {
    friend-list-visible: true,
    status-visible: true,
    metadata-visible: true,
    last-seen-visible: false, ;; Default to private for better security
    profile-image-visible: true,
    encryption-enabled: false,
    analytics-enabled: true,
    public-profile: false,
    last-updated: stacks-block-height,
  }
    (map-get? UserPrivacy user)
  )
)

;; Reputation Calculator - Dynamic Trust Scoring
(define-private (calculate-reputation (user principal))
  (let (
      (activity (default-to { engagement-score: u0, streak-count: u0, total-actions: u0, login-count: u0, last-seen: u0, last-action: u0 } (map-get? UserActivity user)))
      (base-score (+ (get engagement-score activity) (* (get streak-count activity) u2)))
    )
    (+ base-score (/ (get total-actions activity) u10))
  )
)

;; PUBLIC INTERFACE FUNCTIONS - External API Endpoints

;; User Registration - Onboarding New Members
(define-public (register-user 
    (name (string-ascii 64))
    (metadata (optional (string-utf8 512)))
    (public-profile bool)
  )
  (let ((caller tx-sender))
    (asserts! (not (user-exists caller)) ERR_ALREADY_EXISTS)
    (asserts! (> (len name) u0) ERR_INVALID_INPUT)
    (asserts! (<= (len name) MAX_NAME_LENGTH) ERR_INVALID_INPUT)
    
    (map-set Users caller {
      name: name,
      status: STATUS_ACTIVE,
      timestamp: stacks-block-height,
      metadata: metadata,
      deactivation-time: none,
      encryption-key: none,
      profile-image: none,
      reputation-score: u10, ;; Starting reputation
      verification-status: false,
    })
    
    (map-set UserPrivacy caller {
      friend-list-visible: true,
      status-visible: true,
      metadata-visible: true,
      last-seen-visible: false,
      profile-image-visible: true,
      encryption-enabled: false,
      analytics-enabled: true,
      public-profile: public-profile,
      last-updated: stacks-block-height,
    })
    
    (print {
      event: "user-registered",
      user: caller,
      name: name,
      timestamp: stacks-block-height,
    })
    (ok true)
  )
)

;; Intelligent Batch Optimization - Dynamic Performance Tuning
(define-public (optimize-batch-size)
  (let (
      (caller tx-sender)
      (batch-data (default-to {
        message-counter: u0,
        last-batch-timestamp: stacks-block-height,
        batch-size: MIN_BATCH_SIZE,
        current-batch-items: u0,
        total-batches: u0,
        optimization-score: u50,
        processing-efficiency: u50,
      }
        (map-get? UserBatches caller)
      ))
      (current-time stacks-block-height)
      (time-since-last-batch (- current-time (get last-batch-timestamp batch-data)))
      (current-batch-size (get batch-size batch-data))
      (items-in-current-batch (get current-batch-items batch-data))
      (efficiency (get processing-efficiency batch-data))
    )
    (asserts! (check-active-user caller) ERR_DEACTIVATED)
    
    (if (> time-since-last-batch BATCH_EXPIRY_PERIOD)
      ;; Reduce batch size due to inactivity
      (begin
        (map-set UserBatches caller
          (merge batch-data {
            batch-size: (max-uint MIN_BATCH_SIZE (/ current-batch-size u2)),
            current-batch-items: u0,
            last-batch-timestamp: current-time,
            optimization-score: (max-uint u10 (- (get optimization-score batch-data) u5)),
          })
        )
        (ok "batch-size-reduced")
      )
      ;; Optimize based on current usage
      (begin
        (let ((new-size (if (>= items-in-current-batch OPTIMAL_BATCH_THRESHOLD)
                          (min-uint MAX_BATCH_SIZE (* current-batch-size u2))
                          current-batch-size)))
          (map-set UserBatches caller
            (merge batch-data { 
              batch-size: new-size,
              optimization-score: (+ (get optimization-score batch-data) u1),
              processing-efficiency: (+ efficiency u1),
            })
          )
          (ok "batch-optimized")
        )
      )
    )
  )
)