;; PeerSwap - Trustless atomic swaps
(define-constant ERR-DEADLINE-PASSED (err u100))
(define-constant ERR-DEADLINE-NOT-REACHED (err u101))
(define-constant ERR-INVALID-SECRET (err u102))

(define-map swaps
    { swap-id: uint }
    { initiator: principal, counterparty: principal, secret-hash: (buff 32), amount: uint, deadline: uint, completed: bool, refunded: bool }
)

(define-data-var swap-counter uint u0)

(define-public (initiate-swap (counterparty principal) (secret-hash (buff 32)) (duration uint))
    (let (
        (swap-id (var-get swap-counter))
    )
        (map-set swaps { swap-id: swap-id } {
            initiator: tx-sender,
            counterparty: counterparty,
            secret-hash: secret-hash,
            amount: u0,
            deadline: (+ block-height duration),
            completed: false,
            refunded: false
        })
        (var-set swap-counter (+ swap-id u1))
        (ok swap-id)
    )
)

(define-public (complete-swap (swap-id uint) (secret (buff 32)))
    (let (
        (swap (unwrap! (map-get? swaps { swap-id: swap-id }) ERR-DEADLINE-PASSED))
    )
        (asserts! (<= block-height (get deadline swap)) ERR-DEADLINE-PASSED)
        (asserts! (is-eq (keccak256 secret) (get secret-hash swap)) ERR-INVALID-SECRET)
        (map-set swaps { swap-id: swap-id } (merge swap { completed: true }))
        (ok true)
    )
)

(define-public (refund-swap (swap-id uint))
    (let (
        (swap (unwrap! (map-get? swaps { swap-id: swap-id }) ERR-DEADLINE-NOT-REACHED))
    )
        (asserts! (> block-height (get deadline swap)) ERR-DEADLINE-NOT-REACHED)
        (map-set swaps { swap-id: swap-id } (merge swap { refunded: true }))
        (ok true)
    )
)

(define-read-only (get-swap (swap-id uint))
    (map-get? swaps { swap-id: swap-id })
)
