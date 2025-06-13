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

;; Advanced Privacy Configuration - Granular Control Center
(define-public (update-advanced-privacy-settings
    (friend-list-visible bool)
    (status-visible bool)
    (metadata-visible bool)
    (last-seen-visible bool)
    (profile-image-visible bool)
    (encryption-enabled bool)
    (analytics-enabled bool)
    (public-profile bool)
  )
  (let ((caller tx-sender))
    (asserts! (check-active-user caller) ERR_DEACTIVATED)
    (asserts! (check-rate-limit caller u2) ERR_RATE_LIMITED)
    
    (map-set UserPrivacy caller {
      friend-list-visible: friend-list-visible,
      status-visible: status-visible,
      metadata-visible: metadata-visible,
      last-seen-visible: last-seen-visible,
      profile-image-visible: profile-image-visible,
      encryption-enabled: encryption-enabled,
      analytics-enabled: analytics-enabled,
      public-profile: public-profile,
      last-updated: stacks-block-height,
    })
    
    (update-rate-limit caller u2)
    (update-user-activity caller)
    
    (print {
      event: "privacy-settings-updated",
      user: caller,
      encryption-enabled: encryption-enabled,
      public-profile: public-profile,
      timestamp: stacks-block-height,
    })
    (ok true)
  )
)

;; Enhanced Profile Management - Dynamic User Data Updates
(define-public (update-user-profile
    (name (optional (string-ascii 64)))
    (metadata (optional (string-utf8 512)))
    (encryption-key (optional (buff 32)))
    (profile-image (optional (string-utf8 256)))
  )
  (let (
      (caller tx-sender)
      (user (unwrap! (map-get? Users caller) ERR_NOT_FOUND))
    )
    (asserts! (check-active-user caller) ERR_DEACTIVATED)
    (asserts! (check-rate-limit caller u2) ERR_RATE_LIMITED)
    
    ;; Validate name length if provided
    (match name
      new-name (asserts! (and (> (len new-name) u0) (<= (len new-name) MAX_NAME_LENGTH)) ERR_INVALID_INPUT)
      true
    )
    
    (map-set Users caller
      (merge user {
        name: (default-to (get name user) name),
        metadata: (if (is-some metadata) metadata (get metadata user)),
        encryption-key: (if (is-some encryption-key) encryption-key (get encryption-key user)),
        profile-image: (if (is-some profile-image) profile-image (get profile-image user)),
        reputation-score: (calculate-reputation caller),
      })
    )
    
    (update-rate-limit caller u2)
    (update-user-activity caller)
    
    (print {
      event: "profile-updated",
      user: caller,
      has-encryption: (is-some encryption-key),
      timestamp: stacks-block-height,
    })
    (ok true)
  )
)

;; Manual Batch Configuration - Advanced User Control
(define-public (set-batch-size (new-size uint))
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
    )
    (asserts! (check-active-user caller) ERR_DEACTIVATED)
    (asserts! (and (>= new-size MIN_BATCH_SIZE) (<= new-size MAX_BATCH_SIZE)) ERR_INVALID_INPUT)
    
    (map-set UserBatches caller (merge batch-data { batch-size: new-size }))
    (update-user-activity caller)
    
    (print {
      event: "batch-size-manually-set",
      user: caller,
      new-size: new-size,
      timestamp: stacks-block-height,
    })
    (ok true)
  )
)

;; Enhanced Session Management - Security & Analytics Tracking
(define-public (record-login)
  (let (
      (caller tx-sender)
      (activity (default-to {
        last-seen: stacks-block-height,
        login-count: u0,
        total-actions: u0,
        last-action: stacks-block-height,
        streak-count: u0,
        engagement-score: u0,
      }
        (map-get? UserActivity caller)
      ))
    )
    (asserts! (user-exists caller) ERR_NOT_FOUND)
    
    (map-set UserActivity caller
      (merge activity {
        last-seen: stacks-block-height,
        login-count: (+ (get login-count activity) u1),
      })
    )
    
    ;; Update reputation based on consistent logins
    (let ((user-data (unwrap-panic (map-get? Users caller))))
      (map-set Users caller
        (merge user-data {
          reputation-score: (+ (get reputation-score user-data) u1)
        })
      )
    )
    
    (print {
      event: "user-login",
      user: caller,
      login-count: (+ (get login-count activity) u1),
      timestamp: stacks-block-height,
    })
    (ok true)
  )
)

;; Friend Request System - Social Connection Management
(define-public (send-friend-request (target principal))
  (let ((caller tx-sender))
    (asserts! (check-active-user caller) ERR_DEACTIVATED)
    (asserts! (check-active-user target) ERR_NOT_FOUND)
    (asserts! (not (is-eq caller target)) ERR_INVALID_INPUT)
    (asserts! (not (is-blocked caller target)) ERR_BLOCKED)
    (asserts! (check-rate-limit caller u1) ERR_RATE_LIMITED)
    
    ;; Check if friendship already exists
    (asserts! (is-none (map-get? Friendships { user1: caller, user2: target })) ERR_ALREADY_EXISTS)
    (asserts! (is-none (map-get? Friendships { user1: target, user2: caller })) ERR_ALREADY_EXISTS)
    
    (map-set Friendships { user1: caller, user2: target } {
      status: FRIENDSHIP_PENDING,
      created-at: stacks-block-height,
      last-interaction: stacks-block-height,
      interaction-count: u0,
    })
    
    (update-rate-limit caller u1)
    (update-user-activity caller)
    
    (print {
      event: "friend-request-sent",
      from: caller,
      to: target,
      timestamp: stacks-block-height,
    })
    (ok true)
  )
)

;; Accept Friend Request - Social Connection Approval
(define-public (accept-friend-request (requester principal))
  (let ((caller tx-sender))
    (asserts! (check-active-user caller) ERR_DEACTIVATED)
    (asserts! (not (is-blocked caller requester)) ERR_BLOCKED)
    
    (let ((friendship (unwrap! (map-get? Friendships { user1: requester, user2: caller }) ERR_NOT_FOUND)))
      (asserts! (is-eq (get status friendship) FRIENDSHIP_PENDING) ERR_INVALID_INPUT)
      
      (map-set Friendships { user1: requester, user2: caller }
        (merge friendship {
          status: FRIENDSHIP_ACTIVE,
          last-interaction: stacks-block-height,
          interaction-count: u1,
        })
      )
      
      (update-user-activity caller)
      
      (print {
        event: "friend-request-accepted",
        requester: requester,
        accepter: caller,
        timestamp: stacks-block-height,
      })
      (ok true)
    )
  )
)

;; Block User System - Enhanced Safety Mechanism
(define-public (block-user (target principal) (reason (optional (string-utf8 128))))
  (let ((caller tx-sender))
    (asserts! (check-active-user caller) ERR_DEACTIVATED)
    (asserts! (not (is-eq caller target)) ERR_INVALID_INPUT)
    
    (map-set BlockedUsers { blocker: caller, blocked: target } {
      timestamp: stacks-block-height,
      reason: reason,
      report-count: u1,
    })
    
    ;; Remove any existing friendship
    (map-delete Friendships { user1: caller, user2: target })
    (map-delete Friendships { user1: target, user2: caller })
    
    (update-user-activity caller)
    
    (print {
      event: "user-blocked",
      blocker: caller,
      blocked: target,
      has-reason: (is-some reason),
      timestamp: stacks-block-height,
    })
    (ok true)
  )
)

;; READ-ONLY FUNCTIONS - Data Queries & Analytics

;; Get User Profile - Public Data Access
(define-read-only (get-user-profile (user principal))
  (let (
      (user-data (map-get? Users user))
      (privacy (get-privacy-settings user))
    )
    (match user-data
      data (ok {
        name: (get name data),
        status: (get status data),
        timestamp: (get timestamp data),
        metadata: (if (get metadata-visible privacy) (get metadata data) none),
        profile-image: (if (get profile-image-visible privacy) (get profile-image data) none),
        reputation-score: (get reputation-score data),
        verification-status: (get verification-status data),
        is-public: (get public-profile privacy),
      })
      ERR_NOT_FOUND
    )
  )
)

;; Get User Activity Stats - Analytics Dashboard
(define-read-only (get-user-activity (user principal))
  (let ((privacy (get-privacy-settings user)))
    (if (get analytics-enabled privacy)
      (ok (map-get? UserActivity user))
      ERR_UNAUTHORIZED
    )
  )
)

;; Check Friendship Status - Relationship Query
(define-read-only (check-friendship-status (user1 principal) (user2 principal))
  (match (map-get? Friendships { user1: user1, user2: user2 })
    friendship (ok (get status friendship))
    (match (map-get? Friendships { user1: user2, user2: user1 })
      friendship (ok (get status friendship))
      (ok u404) ;; No relationship exists
    )
  )
)

;; Get Platform Statistics - Global Analytics
(define-read-only (get-platform-stats)
  (ok {
    version: "1.0.0",
    network: "Stacks Mainnet",
    features: (list "privacy-controls" "batch-optimization" "anti-spam" "reputation-system"),
    contract-address: (as-contract tx-sender)
  })
)

;; CONTRACT INITIALIZATION & METADATA

;; Contract deployment initialization
(begin
  (print {
    event: "bitsocial-deployed",
    version: "1.0.0",
    deployer: tx-sender,
    timestamp: stacks-block-height,
    features: (list "user-management" "privacy-controls" "social-graph" "batch-optimization" "reputation-system")
  })
)