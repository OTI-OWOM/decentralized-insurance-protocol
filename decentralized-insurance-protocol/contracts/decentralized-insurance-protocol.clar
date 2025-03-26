;; title: decentralized-insurance-protocol

;; Decentralized Insurance Protocol
;; A community-driven insurance platform on Stacks

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-FUNDS (err u2))
(define-constant ERR-INVALID-CLAIM (err u3))
(define-constant ERR-POOL-CLOSED (err u4))
(define-constant ERR-ALREADY-CLAIMED (err u5))
(define-constant ERR-INSUFFICIENT-LIQUIDITY (err u6))
(define-constant ERR-CLAIM-NOT-APPROVED (err u7))

;; Governance Token
(define-fungible-token INSURANCE-GOVERNANCE-TOKEN u1000000)

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

;; Purchase insurance policy
(define-public (purchase-policy
    (pool-id uint)
    (coverage-amount uint)
)
    (begin
        ;; Validate pool exists and is active
        (let 
            (
                (pool (unwrap! 
                    (map-get? insurance-pools 
                        {
                            pool-id: pool-id,
                            insurance-type: "default"
                        }
                    ) 
                    ERR-INVALID-CLAIM)
                )
                (premium (/ (* coverage-amount (get premium-rate pool)) u100))
            )
            
            ;; Ensure pool is active and coverage is within limits
            (asserts! (get active pool) ERR-POOL-CLOSED)
            (asserts! (<= coverage-amount (get max-coverage pool)) ERR-UNAUTHORIZED)
            
            ;; Record policy holder
            (map-set policy-holders 
                {
                    pool-id: pool-id,
                    holder: tx-sender
                }
                {
                    coverage-amount: coverage-amount,
                    premium-paid: premium,
                    claim-status: "active"
                }
            )
            
            (ok true)
        )
    )
)

;; Approve claim (only contract owner)
(define-public (approve-claim
    (pool-id uint)
    (claim-id uint)
)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
        
        (let 
            (
                (claim (unwrap! 
                    (map-get? claims 
                        {
                            pool-id: pool-id,
                            claim-id: claim-id
                        }
                    ) 
                    ERR-INVALID-CLAIM)
                )
            )
            
            ;; Update claim status
            (map-set claims 
                {
                    pool-id: pool-id,
                    claim-id: claim-id
                }
                (merge claim {
                    approved: true,
                    resolved: true
                })
            )
            
            (ok true)
        )
    )
)

;; Helper read-only functions
(define-read-only (get-last-pool-id)
    (ok u0)
)

(define-read-only (get-last-claim-id)
    (ok u0)
)

;; Get pool details
(define-read-only (get-pool-details (pool-id uint))
    (map-get? insurance-pools 
        {
            pool-id: pool-id,
            insurance-type: "default"
        }
    )
)

;; Get policy details
(define-read-only (get-policy-details (pool-id uint) (holder principal))
    (map-get? policy-holders 
        {
            pool-id: pool-id,
            holder: holder
        }
    )
)


;; Governance Token Distribution
(define-public (distribute-governance-tokens
    (pool-id uint)
    (recipient principal)
    (amount uint)
)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
        (ft-mint? INSURANCE-GOVERNANCE-TOKEN amount recipient)
    )
)

;; Claim Rating Mapping
(define-map claim-ratings
    {
        pool-id: uint,
        claim-id: uint,
        voter: principal
    }
    {
        rating: uint,
        voted: bool
    }
)

(define-constant ERR-INSUFFICIENT-STAKE (err u8))
(define-constant ERR-INVALID-PROPOSAL (err u9))
(define-constant ERR-DISPUTE-FAILED (err u10))

(define-fungible-token INSURANCE-STAKE-TOKEN u500000)

(define-map governance-proposals
    {
        proposal-id: uint,
        proposer: principal
    }
    {
        proposal-type: (string-ascii 32),
        description: (string-ascii 200),
        votes-for: uint,
        votes-against: uint,
        executed: bool
    }
)


