import League from 0xTOPSHOTADDRESS
import Market from 0xMARKETADDRESS

// This transaction is for a user to stop a film sale in their account
// by withdrawing that film from their sale collection and depositing
// it into their normal film collection

// Parameters
//
// tokenID: the ID of the film whose sale is to be delisted

transaction(tokenID: UInt64) {

    let collectionRef: &League.Collection
    let saleCollectionRef: &Market.SaleCollection

    prepare(acct: AuthAccount) {

        // Borrow a reference to the NFT collection in the signers account
        self.collectionRef = acct.borrow<&League.Collection>(from: /storage/FilmCollection)
            ?? panic("Could not borrow from FilmCollection in storage")

        // borrow a reference to the owner's sale collection
        self.saleCollectionRef = acct.borrow<&Market.SaleCollection>(from: /storage/topshotSaleCollection)
            ?? panic("Could not borrow from sale in storage")
    }

    execute {
    
        // withdraw the film from the sale, thereby de-listing it
        let token <- self.saleCollectionRef.withdraw(tokenID: tokenID)

        // deposit the film into the owner's collection
        self.collectionRef.deposit(token: <-token)
    }
}   