import LeagueHeros from "../../contracts/LeagueHeros.cdc"

// This transaction is for retiring all plays from a match, which
// makes it so that films can no longer be minted
// from all the editions with that match

// Parameters:
//
// matchID: the ID of the match to be retired entirely

transaction(matchID: UInt32) {
    let adminRef: &LeagueHeros.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&LeagueHeros.Admin>(from: /storage/LeagueHerosAdmin)
            ?? panic("No admin resource in storage")
    }

    execute {
        // borrow a reference to the specified match
        let matchRef = self.adminRef.borrowMatch(matchID: matchID)

        // retire all the plays
        matchRef.retireAll()
    }
}