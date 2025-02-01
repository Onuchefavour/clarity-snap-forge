# SnapForge

A photography-focused NFT platform built on Stacks. This smart contract enables photographers to mint their photos as NFTs with associated metadata including camera settings, location, and rights information.

## Features
- Mint photo NFTs with rich metadata
- Transfer NFT ownership
- Manage creator royalties
- Query photo and creator details
- Support for limited editions
- Integrated marketplace functionality
  - List photos for sale
  - Purchase photos with automatic royalty distribution
  - Delist photos from marketplace
  - View active listings

## Getting Started
1. Clone the repository
2. Install dependencies with `clarinet install`
3. Run tests with `clarinet test`

## Contract Functions
### Core NFT Functions
- `mint-photo`: Create a new photo NFT
- `transfer`: Transfer an NFT to another user
- `get-photo-details`: Get metadata for a specific photo
- `update-royalty`: Update royalty percentage
- `get-creator`: Get the creator of a photo NFT

### Marketplace Functions
- `list-photo`: List a photo NFT for sale with specified price
- `delist-photo`: Remove a photo from marketplace listings
- `buy-photo`: Purchase a listed photo with automatic royalty distribution
- `get-listing`: Get details of a specific marketplace listing
- `get-active-listings`: Get all active marketplace listings

## Marketplace Details
The integrated marketplace allows photographers to:
- List their photos for sale in STX
- Set custom prices
- Receive automatic royalty payments on secondary sales
- Manage their listings with delist functionality
- View all active marketplace listings
