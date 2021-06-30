import NonFungibleToken from 0xNFTADDRESS
import League from 0xTOPSHOTADDRESS
import LeagueShardedCollection from 0xSHARDEDADDRESS

// This transaction is what Top Shot uses to send the films in a "pack" to
// a user's collection

// Parameters:
//
// recipientAddr: the Flow address of the account receiving a pack of films
// filmsIDs: an array of film IDs to be withdrawn from the owner's film collection

transaction(recipientAddr: Address, filmIDs: [UInt64]) {

    prepare(acct: AuthAccount) {
        
        // get the recipient's public account object
        let recipient = getAccount(recipientAddr)

        // borrow a reference to the recipient's film collection
        let receiverRef = recipient.getCapability(/public/FilmCollection)
            .borrow<&{League.FilmCollectionPublic}>()
            ?? panic("Could not borrow reference to receiver's collection")

        

        // borrow a reference to the owner's film collection
        if let collection = acct.borrow<&LeagueShardedCollection.ShardedCollection>(from: /storage/ShardedFilmCollection) {
            
            receiverRef.batchDeposit(tokens: <-collection.batchWithdraw(ids: filmIDs))
        } else {

            let collection = acct.borrow<&League.Collection>(from: /storage/FilmCollection)!

            // Deposit the pack of films to the recipient's collection
            receiverRef.batchDeposit(tokens: <-collection.batchWithdraw(ids: filmIDs))

        }
    }
}