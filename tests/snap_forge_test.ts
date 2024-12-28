import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can mint a new photo NFT",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('snap-forge', 'mint-photo', [
                types.utf8("Sunset at Beach"),
                types.utf8("Beautiful sunset captured at Venice Beach"),
                types.ascii("Canon EOS R5"),
                types.ascii("f/2.8, 1/1000s, ISO 100"),
                types.utf8("Venice Beach, CA"),
                types.uint(1625097600),
                types.uint(10),
                types.uint(10)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk();
        block.receipts[0].events.expectNonFungibleTokenMint("snap-photo", "1", deployer.address);
    }
});

Clarinet.test({
    name: "Can transfer photo NFT",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('snap-forge', 'mint-photo', [
                types.utf8("Mountain Peak"),
                types.utf8("Snowy mountain peak at sunrise"),
                types.ascii("Sony A7III"),
                types.ascii("f/4, 1/2000s, ISO 200"),
                types.utf8("Mt. Whitney"),
                types.uint(1625097600),
                types.uint(1),
                types.uint(5)
            ], deployer.address),
            Tx.contractCall('snap-forge', 'transfer', [
                types.uint(1),
                types.principal(wallet1.address)
            ], deployer.address)
        ]);
        
        block.receipts[1].result.expectOk();
        block.receipts[1].events.expectNonFungibleTokenTransfer(
            "snap-photo",
            "1",
            deployer.address,
            wallet1.address
        );
    }
});

Clarinet.test({
    name: "Can get photo details",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('snap-forge', 'mint-photo', [
                types.utf8("City Lights"),
                types.utf8("Night cityscape"),
                types.ascii("Fuji X-T4"),
                types.ascii("f/8, 30s, ISO 400"),
                types.utf8("New York City"),
                types.uint(1625097600),
                types.uint(5),
                types.uint(5)
            ], deployer.address)
        ]);
        
        let photoDetails = chain.callReadOnlyFn(
            'snap-forge',
            'get-photo-details',
            [types.uint(1)],
            deployer.address
        );
        
        photoDetails.result.expectSome().expectTuple();
    }
});