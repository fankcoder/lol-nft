import League from 0xNFTADDRESS
import Market from 0xMARKETADDRESS

// This transaction is for a user to put a new film up for sale
// They must have League Collection and a Market Sale Collection
// stored in their account

// Parameters
//
// filmId: the ID of the film to be listed for sale
// price: the sell price of the film

transaction(filmID: UInt64, price: UFix64) {

    let collectionRef: &League.Collection
    let saleCollectionRef: &Market.SaleCollection

    prepare(acct: AuthAccount) {

        // borrow a reference to the Top Shot Collection
        self.collectionRef = acct.borrow<&League.Collection>(from: /storage/FilmCollection)
            ?? panic("Could not borrow from FilmCollection in storage")

        // borrow a reference to the topshot Sale Collection
        self.saleCollectionRef = acct.borrow<&Market.SaleCollection>(from: /storage/topshotSaleCollection)
            ?? panic("Could not borrow from sale in storage")
    }

    execute {

        // withdraw the specified token from the collection
        let token <- self.collectionRef.withdraw(withdrawID: filmID) as! @League.NFT

        // List the specified film for sale
        self.saleCollectionRef.listForSale(token: <-token, price: price)
    }
}