import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

[... original tests ...]

Clarinet.test({
    name: "Cannot transfer listed photo",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const recipient = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('snap-forge', 'mint-photo', [
                types.utf8("Test Photo"),
                types.utf8("Test Description"),
                types.ascii("Test Camera"),
                types.ascii("Test Settings"),
                types.utf8("Test Location"),
                types.uint(1625097600),
                types.uint(1),
                types.uint(5)
            ], deployer.address),
            Tx.contractCall('snap-forge', 'list-photo', [
                types.uint(1),
                types.uint(1000000)
            ], deployer.address),
            Tx.contractCall('snap-forge', 'transfer', [
                types.uint(1),
                types.principal(recipient.address)
            ], deployer.address)
        ]);
        
        block.receipts[2].result.expectErr(106); // err-listing-active
    }
});
