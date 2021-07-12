import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import LeagueHeros from "../../contracts/LeagueHeros.cdc"

// This transaction transfers a number of films to a recipient

// Parameters
//
// recipientAddress: the Flow address who will receive the NFTs
// filmIDs: an array of film IDs of NFTs that recipient will receive

transaction(recipientAddress: Address, filmIDs: [UInt64]) {

    let transferTokens: @NonFungibleToken.Collection
    
    prepare(acct: AuthAccount) {

        self.transferTokens <- acct.borrow<&LeagueHeros.Collection>(from: /storage/FilmCollection)!.batchWithdraw(ids: filmIDs)
    }

    execute {
        
        // get the recipient's public account object
        let recipient = getAccount(recipientAddress)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/FilmCollection).borrow<&{LeagueHeros.FilmCollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipients film receiver")

        // deposit the NFT in the receivers collection
        receiverRef.batchDeposit(token: <-self.transferTokens)
    }
}