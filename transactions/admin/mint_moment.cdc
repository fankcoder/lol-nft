import League from 0xTOPSHOTADDRESS

// This transaction is what an admin would use to mint a single new film
// and deposit it in a user's collection

// Parameters:
//
// matchID: the ID of a match containing the target play
// playID: the ID of a play from which a new film is minted
// recipientAddr: the Flow address of the account receiving the newly minted film

transaction(matchID: UInt32, playID: UInt32, recipientAddr: Address, ipfs:String) {
    // local variable for the admin reference
    let adminRef: &League.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&League.Admin>(from: /storage/LeagueAdmin)!
    }

    execute {
        // Borrow a reference to the specified match
        let matchRef = self.adminRef.borrowMatch(matchID: matchID)

        // Mint a new NFT
        let film1 <- matchRef.mintFilm(playID: playID, ipfs: ipfs)

        // get the public account object for the recipient
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/FilmCollection).borrow<&{League.FilmCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's film collection")

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-film1)
    }
}