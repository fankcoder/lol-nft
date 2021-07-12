import LeagueHeros from "../../contracts/LeagueHeros.cdc"

// This transaction mints multiple films
// from a single match/play combination (otherwise known as edition)

// Parameters:
//
// matchID: the ID of the match to be minted from
// playID: the ID of the Play from which the Films are minted
// quantity: the quantity of Films to be minted
// recipientAddr: the Flow address of the account receiving the collection of minted films

transaction(matchID: UInt32, playID: UInt32, quantity: UInt64, recipientAddr: Address, ipfs: String) {

    // Local variable for the topshot Admin object
    let adminRef: &LeagueHeros.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&LeagueHeros.Admin>(from: /storage/LeagueHerosAdmin)!
    }

    execute {

        // borrow a reference to the match to be minted from
        let matchRef = self.adminRef.borrowMatch(matchID: matchID)

        // Mint all the new NFTs
        let collection <- matchRef.batchMintFilm(playID: playID, quantity: quantity, ipfs: ipfs)

        // Get the account object for the recipient of the minted tokens
        let recipient = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(/public/FilmCollection).borrow<&{LeagueHeros.FilmCollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collection")

        // deposit the NFT in the receivers collection
        receiverRef.batchDeposit(tokens: <-collection)
    }
}