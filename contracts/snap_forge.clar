;; SnapForge - Photography NFT Platform

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101)) 
(define-constant err-invalid-params (err u102))
(define-constant err-token-exists (err u103))
(define-constant err-listing-not-found (err u104))
(define-constant err-invalid-price (err u105))
(define-constant err-listing-active (err u106))
(define-constant err-invalid-recipient (err u107))
(define-constant err-invalid-date (err u108))
(define-constant MAX-EDITION-SIZE u1000)

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

(define-private (is-listed (token-id uint))
    (match (map-get? marketplace-listings token-id)
        listing (get active listing)
        false
    )
)

(define-private (is-valid-date (date uint))
    (< date (get-block-time))
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
        (asserts! (<= edition-total MAX-EDITION-SIZE) err-invalid-params)
        (asserts! (not (is-eq title "")) err-invalid-params)
        (asserts! (is-valid-date date-taken) err-invalid-date)
        
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

(define-public (transfer (token-id uint) (recipient principal))
    (begin
        (asserts! (is-token-owner token-id tx-sender) err-not-token-owner)
        (asserts! (not (is-listed token-id)) err-listing-active)
        (asserts! (is-some (principal-get-contract-id? recipient)) err-invalid-recipient)
        (nft-transfer? snap-photo token-id tx-sender recipient)
    )
)

[... rest of the original contract functions ...]
