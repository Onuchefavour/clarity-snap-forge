;; SnapForge - Photography NFT Platform

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-invalid-params (err u102))
(define-constant err-token-exists (err u103))

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

(define-data-var last-token-id uint u0)

;; Private Functions
(define-private (is-token-owner (token-id uint) (user principal))
    (is-eq user (unwrap! (nft-get-owner? snap-photo token-id) false))
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