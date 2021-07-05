import League from 0xNFTADDRESS
import Market from 0xMARKETADDRESS
import LeagueMarketV2 from 0xMARKETV2ADDRESS

// This transaction is for a user to change a moment sale from
// the first version of the market contract to the second version

// Parameters
//
// tokenID: the ID of the moment whose sale is to be upgraded

transaction(tokenID: UInt64, price: UFix64) {

    prepare(acct: AuthAccount) {

        // Borrow a reference to the NFT collection in the signers account	
        let nftCollection = acct.borrow<&League.Collection>(from: /storage/FilmCollection)
            ?? panic("Could not borrow from FilmCollection in storage")

        // borrow a reference to the owner's sale collection
        let topshotSaleCollection = acct.borrow<&Market.SaleCollection>(from: /storage/topshotSaleCollection)
            ?? panic("Could not borrow from sale in storage")

        let topshotSaleV2Collection = acct.borrow<&LeagueMarketV2.SaleCollection>(from: LeagueMarketV2.marketStoragePath)
            ?? panic("Could not borrow reference to sale V2 in storage")

        // withdraw the moment from the sale, thereby de-listing it
        let token <- topshotSaleCollection.withdraw(tokenID: tokenID)

        // deposit the moment into the owner's collection	
        nftCollection.deposit(token: <-token)

        // List the specified moment for sale
        topshotSaleV2Collection.listForSale(tokenID: tokenID, price: price)

    }
}