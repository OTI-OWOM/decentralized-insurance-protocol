;; title: decentralized-insurance-protocol

;; Decentralized Insurance Protocol
;; A community-driven insurance platform on Stacks

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-FUNDS (err u2))
(define-constant ERR-INVALID-CLAIM (err u3))
(define-constant ERR-POOL-CLOSED (err u4))
(define-constant ERR-ALREADY-CLAIMED (err u5))

;; Insurance Pool Storage
(define-map insurance-pools
    {
        pool-id: uint,
        insurance-type: (string-ascii 32)
    }
    {
        total-liquidity: uint,
        premium-rate: uint,
        max-coverage: uint,
        active: bool
    }
)


