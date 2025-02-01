;; SnapForge - Photography NFT Platform

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101)) 
(define-constant err-invalid-params (err u102))
(define-constant err-token-exists (err u103))
(define-constant err-listing-not-found (err u104))
(define-constant err-invalid-price (err u105))

;; Define NFT
(define-non-fungible-token snap-photo uint)

;; Data Variables 
(define-map photo-metadata
    uint
    {
        creator: principal,
        title: (string-utf8 100),
        description: (string-utf8 500),
        camera: (string-ascii 50), 
        settings: (string-ascii 100),
        location: (string-utf8 100),
        date-taken: uint,
        edition-number: uint,
        edition-total: uint,
        royalty: uint
    }
)

(define-map marketplace-listings
    uint 
    {
        seller: principal,
        price: uint,
        listed-at: uint,
        active: bool
    }
)

(define-data-var last-token-id uint u0)

;; Private Functions
(define-private (is-token-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? snap-photo token-id) false))
)

(define-private (calculate-royalty (price uint) (royalty uint))
    (/ (* price royalty) u100)
)

;; Public Functions
(define-public (mint-photo (title (string-utf8 100)) 
                          (description (string-utf8 500))
                          (camera (string-ascii 50))
                          (settings (string-ascii 100))
                          (location (string-utf8 100))
                          (date-taken uint)
                          (edition-total uint)
                          (royalty uint))
    (let
        (
            (token-id (+ (var-get last-token-id) u1))
        )
        (asserts! (<= royalty u100) err-invalid-params)
        (asserts! (> edition-total u0) err-invalid-params)
        
        (try! (nft-mint? snap-photo token-id tx-sender))
        (map-set photo-metadata token-id
            {
                creator: tx-sender,
                title: title,
                description: description,
                camera: camera,
                settings: settings,
                location: location,
                date-taken: date-taken,
                edition-number: u1,
                edition-total: edition-total,
                royalty: royalty
            }
        )
        (var-set last-token-id token-id)
        (ok token-id)
    )
)

(define-public (list-photo (token-id uint) (price uint))
    (let
        (
            (metadata (unwrap! (map-get? photo-metadata token-id) err-invalid-params))
        )
        (asserts! (is-token-owner token-id tx-sender) err-not-token-owner)
        (asserts! (> price u0) err-invalid-price)
        
        (map-set marketplace-listings token-id
            {
                seller: tx-sender,
                price: price,
                listed-at: block-height,
                active: true
            }
        )
        (ok true)
    )
)

(define-public (delist-photo (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? marketplace-listings token-id) err-listing-not-found))
        )
        (asserts! (is-eq (get seller listing) tx-sender) err-not-token-owner)
        (asserts! (get active listing) err-listing-not-found)
        
        (map-set marketplace-listings token-id
            (merge listing { active: false })
        )
        (ok true)
    )
)

(define-public (buy-photo (token-id uint))
    (let
        (
            (listing (unwrap! (map-get? marketplace-listings token-id) err-listing-not-found))
            (metadata (unwrap! (map-get? photo-metadata token-id) err-invalid-params))
            (price (get price listing))
            (seller (get seller listing))
            (royalty-amount (calculate-royalty price (get royalty metadata)))
        )
        (asserts! (get active listing) err-listing-not-found)
        
        ;; Transfer STX payment
        (try! (stx-transfer? price tx-sender seller))
        
        ;; Pay royalties to creator if not the seller
        (if (not (is-eq seller (get creator metadata)))
            (try! (stx-transfer? royalty-amount tx-sender (get creator metadata)))
            true
        )
        
        ;; Transfer NFT
        (try! (nft-transfer? snap-photo token-id seller tx-sender))
        
        ;; Update listing
        (map-set marketplace-listings token-id
            (merge listing { active: false })
        )
        (ok true)
    )
)

(define-public (transfer (token-id uint) (recipient principal))
    (begin
        (asserts! (is-token-owner token-id tx-sender) err-not-token-owner)
        (nft-transfer? snap-photo token-id tx-sender recipient)
    )
)

(define-public (update-royalty (token-id uint) (new-royalty uint))
    (let
        (
            (metadata (unwrap! (map-get? photo-metadata token-id) err-invalid-params))
        )
        (asserts! (is-eq (get creator metadata) tx-sender) err-not-token-owner)
        (asserts! (<= new-royalty u100) err-invalid-params)
        
        (map-set photo-metadata token-id
            (merge metadata { royalty: new-royalty })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-photo-details (token-id uint))
    (map-get? photo-metadata token-id)
)

(define-read-only (get-creator (token-id uint))
    (get creator (unwrap! (map-get? photo-metadata token-id) err-invalid-params))
)

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-listing (token-id uint))
    (map-get? marketplace-listings token-id)
)

(define-read-only (get-active-listings)
    (filter active (map-to-list marketplace-listings))
)
