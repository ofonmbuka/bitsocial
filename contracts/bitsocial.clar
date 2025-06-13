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