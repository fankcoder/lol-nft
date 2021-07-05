import League from 0xNFTADDRESS
import LeagueMarketV2 from 0xMARKETV2ADDRESS

// This transaction is for a user to put a new moment up for sale
// They must have League Collection and a LeagueMarketV2 Sale Collection already
// stored in their account

// Parameters
//
// momentId: the ID of the moment to be listed for sale
// price: the sell price of the moment

transaction(momentID: UInt64, price: UFix64) {
    prepare(acct: AuthAccount) {

        // borrow a reference to the topshot Sale Collection
        let topshotSaleCollection = acct.borrow<&LeagueMarketV2.SaleCollection>(from: LeagueMarketV2.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")

        // List the specified moment for sale
        topshotSaleCollection.listForSale(tokenID: momentID, price: price)
    }
}