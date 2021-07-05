import NonFungibleToken from 0xNFTADDRESS
import League from 0xNFTADDRESS

// This transaction transfers a film to a recipient

// This transaction is how a topshot user would transfer a film
// from their account to another account
// The recipient must have a League Collection object stored
// and a public FilmCollectionPublic capability stored at
// `/public/FilmCollection`

// Parameters:
//
// recipient: The Flow address of the account to receive the film.
// withdrawID: The id of the film to be transferred

transaction(recipient: Address, withdrawID: UInt64) {

    // local variable for storing the transferred token
    let transferToken: @NonFungibleToken.NFT
    
    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's collection
        let collectionRef = acct.borrow<&League.Collection>(from: /storage/FilmCollection)
            ?? panic("Could not borrow a reference to the stored Film collection")
        
        // withdraw the NFT
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        
        // get the recipient's public account object
        let recipient = getAccount(recipient)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/FilmCollection).borrow<&{League.FilmCollectionPublic}>()!

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-self.transferToken)
    }
}