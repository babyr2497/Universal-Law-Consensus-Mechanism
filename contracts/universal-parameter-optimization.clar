;; Fundamental Constant Proposal Contract
;; Allows for proposing changes to fundamental constants in a theoretical universe

(define-data-var admin principal tx-sender)

;; Data structure for a constant proposal
(define-map constant-proposals
  { proposal-id: uint }
  {
    proposer: principal,
    constant-name: (string-ascii 50),
    current-value: int,
    proposed-value: int,
    votes-for: uint,
    votes-against: uint,
    status: (string-ascii 20)
  }
)

;; Counter for proposal IDs
(define-data-var next-proposal-id uint u1)

;; Submit a proposal for a new fundamental constant value
(define-public (propose-constant-change (constant-name (string-ascii 50)) (current-value int) (proposed-value int))
  (let ((proposal-id (var-get next-proposal-id)))
    (map-set constant-proposals
      { proposal-id: proposal-id }
      {
        proposer: tx-sender,
        constant-name: constant-name,
        current-value: current-value,
        proposed-value: proposed-value,
        votes-for: u0,
        votes-against: u0,
        status: "pending"
      }
    )
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)
  )
)

;; Vote on a constant proposal
(define-public (vote-on-proposal (proposal-id uint) (vote-for bool))
  (let (
    (proposal (unwrap! (map-get? constant-proposals { proposal-id: proposal-id }) (err u1)))
    (votes-for (get votes-for proposal))
    (votes-against (get votes-against proposal))
    )
    (if vote-for
      (map-set constant-proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-for: (+ votes-for u1) })
      )
      (map-set constant-proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-against: (+ votes-against u1) })
      )
    )
    (ok true)
  )
)

;; Finalize a proposal if it has enough votes
(define-public (finalize-proposal (proposal-id uint))
  (let (
    (proposal (unwrap! (map-get? constant-proposals { proposal-id: proposal-id }) (err u1)))
    (votes-for (get votes-for proposal))
    (votes-against (get votes-against proposal))
    )
    ;; Simple majority rule
    (if (> votes-for votes-against)
      (map-set constant-proposals
        { proposal-id: proposal-id }
        (merge proposal { status: "approved" })
      )
      (map-set constant-proposals
        { proposal-id: proposal-id }
        (merge proposal { status: "rejected" })
      )
    )
    (ok true)
  )
)

;; Read a proposal's details
(define-read-only (get-proposal (proposal-id uint))
  (map-get? constant-proposals { proposal-id: proposal-id })
)
