import League from 0xTOPSHOTADDRESS
import Market from 0xMARKETADDRESS

// This transaction changes the price of a film that a user has for sale

// Parameters:
//
// tokenID: the ID of the film whose price is being changed
// newPrice: the new price of the film

transaction(tokenID: UInt64, newPrice: UFix64) {

    // Local variable for the account's topshot sale collection
    let topshotSaleCollectionRef: &Market.SaleCollection

    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's sale collection
        self.topshotSaleCollectionRef = acct.borrow<&Market.SaleCollection>(from: /storage/topshotSaleCollection)
            ?? panic("Could not borrow from sale in storage")
    }

    execute {

        // Change the price of the film
        self.topshotSaleCollectionRef.changePrice(tokenID: tokenID, newPrice: newPrice)
    }

    
}