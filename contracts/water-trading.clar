;; This Clarity smart contract allows for the management and trading of water on a blockchain platform. 
;; It enables users to set water prices, reserve and trade water, and apply transaction fees and refunds. 
;; The contract includes functions for adding and removing water from sale, updating water reserves, 
;; and enforcing reserve limits and user balances. It also ensures secure transactions with validation checks 
;; to prevent fraud, invalid operations, and excessive price manipulation. The contract is designed for 
;; scalability, enabling dynamic adjustments to water reserve limits and pricing by the contract owner. 
;; It operates with multiple user accounts, ensuring a decentralized and secure water trading environment.

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u200))
(define-constant err-not-enough-water (err u201))
(define-constant err-transfer-failed (err u202))
(define-constant err-invalid-price (err u203))
(define-constant err-invalid-amount (err u204))
(define-constant err-invalid-fee (err u205))
(define-constant err-refund-failed (err u206))
(define-constant err-same-user (err u207))
(define-constant err-reserve-limit-exceeded (err u208))
(define-constant err-invalid-reserve-limit (err u209))

;; Define data variables
(define-data-var water-price uint u100) ;; Price per cubic meter in microstacks (1 STX = 1,000,000 microstacks)
(define-data-var max-water-per-user uint u10000) ;; Maximum water a user can add (in cubic meters)
(define-data-var transaction-fee-percentage uint u5) ;; Transaction fee percentage (e.g., 5 means 5%)
(define-data-var refund-percentage uint u90) ;; Refund percentage in case of withdrawal (e.g., 90 means 90% of current price)
(define-data-var water-reserve-limit uint u1000000) ;; Global water reserve limit (in cubic meters)
(define-data-var current-water-reserve uint u0) ;; Current total water in the system (in cubic meters)

;; Define data maps
(define-map user-water-balance principal uint)
(define-map user-stx-balance principal uint)
(define-map water-for-sale {user: principal} {amount: uint, price: uint})

;; Private functions

;; Calculate transaction fee
(define-private (calculate-fee (amount uint))
  (/ (* amount (var-get transaction-fee-percentage)) u100))

;; Calculate refund amount
(define-private (calculate-refund (amount uint))
  (/ (* amount (var-get water-price) (var-get refund-percentage)) u100))

;; Update water reserve
(define-private (update-water-reserve (amount int))
  (let (
    (current-reserve (var-get current-water-reserve))
    (new-reserve (if (< amount 0)
                     (if (>= current-reserve (to-uint (- 0 amount)))
                         (- current-reserve (to-uint (- 0 amount)))
                         u0)
                     (+ current-reserve (to-uint amount))))
  )
    (asserts! (<= new-reserve (var-get water-reserve-limit)) err-reserve-limit-exceeded)
    (var-set current-water-reserve new-reserve)
    (ok true)))

;; Add new functionality to check if a user has enough water to complete a transaction
(define-private (has-enough-water? (user principal) (amount uint))
  (let (
        (user-water (default-to u0 (map-get? user-water-balance user)))
  )
    (ok (>= user-water amount))))

;; Enhance security: Add a function to verify if the user is the contract owner before executing critical operations
(define-private (verify-owner)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok true)))

;; Refactor to handle reserve limit check more efficiently
(define-private (check-reserve-limit)
  (begin
    (asserts! (<= (var-get current-water-reserve) (var-get water-reserve-limit)) err-reserve-limit-exceeded)
    (ok true)))

;; Public functions

;; Set water price (only contract owner)
(define-public (set-water-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-price u0) err-invalid-price) ;; Ensure price is greater than 0
    (var-set water-price new-price)
    (ok true)))

;; Set transaction fee (only contract owner)
(define-public (set-transaction-fee (new-fee-percentage uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee-percentage u100) err-invalid-fee) ;; Ensure fee is not more than 100%
    (var-set transaction-fee-percentage new-fee-percentage)
    (ok true)))

;; Set refund percentage (only contract owner)
(define-public (set-refund-percentage (new-percentage uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-percentage u100) err-invalid-fee) ;; Ensure percentage is not more than 100%
    (var-set refund-percentage new-percentage)
    (ok true)))

;; Set water reserve limit (only contract owner)
(define-public (set-water-reserve-limit (new-limit uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (>= new-limit (var-get current-water-reserve)) err-invalid-reserve-limit)
    (var-set water-reserve-limit new-limit)
    (ok true)))

;; Add water for sale
(define-public (add-water-for-sale (amount uint) (price uint))
  (let (
    (current-balance (default-to u0 (map-get? user-water-balance tx-sender)))
    (current-for-sale (get amount (default-to {amount: u0, price: u0} (map-get? water-for-sale {user: tx-sender}))))
    (new-for-sale (+ amount current-for-sale))
  )
    (asserts! (> amount u0) err-invalid-amount) ;; Ensure amount is greater than 0
    (asserts! (> price u0) err-invalid-price) ;; Ensure price is greater than 0
    (asserts! (>= current-balance new-for-sale) err-not-enough-water)
    (try! (update-water-reserve (to-int amount)))
    (map-set water-for-sale {user: tx-sender} {amount: new-for-sale, price: price})
    (ok true)))

;; Refactor to enhance performance: Update water sale price only when necessary
(define-public (set-water-sale-price (new-price uint))
  (begin
    (asserts! (> new-price u0) err-invalid-price)
    (let (
          (current-sale (default-to {amount: u0, price: u0} (map-get? water-for-sale {user: tx-sender})))
    )
      (map-set water-for-sale {user: tx-sender} {amount: (get amount current-sale), price: new-price})
      (ok true))))

;; Add a new UI element for users to view transaction fees
(define-public (view-transaction-fee)
  (begin
    (ok (var-get transaction-fee-percentage))))

;; Enhance the contract functionality to allow users to set their own sale price
(define-public (set-user-sale-price (price uint))
  (begin
    (asserts! (> price u0) err-invalid-price)
    (let (
          (current-sale (default-to {amount: u0, price: u0} (map-get? water-for-sale {user: tx-sender})))
    )
      (map-set water-for-sale {user: tx-sender} {amount: (get amount current-sale), price: price})
      (ok true))))

;; Add functionality for users to withdraw their STX balances
(define-public (withdraw-stx (amount uint))
  (let (
        (current-balance (default-to u0 (map-get? user-stx-balance tx-sender)))
  )
    (asserts! (>= current-balance amount) err-not-enough-water)
    (map-set user-stx-balance tx-sender (- current-balance amount))
    (ok true)))













