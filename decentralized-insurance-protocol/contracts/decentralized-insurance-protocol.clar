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

;; Policy Holder Mapping
(define-map policy-holders
    {
        pool-id: uint,
        holder: principal
    }
    {
        coverage-amount: uint,
        premium-paid: uint,
        claim-status: (string-ascii 20)
    }
)

;; Claims Mapping
(define-map claims
    {
        pool-id: uint,
        claim-id: uint
    }
    {
        claimant: principal,
        claim-amount: uint,
        claim-timestamp: uint,
        approved: bool,
        resolved: bool
    }
)



