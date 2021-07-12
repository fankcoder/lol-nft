import LeagueHeros from "../../contracts/LeagueHeros.cdc"

// This is a transaction an admin would use to retire all the plays in a match
// which makes it so that no more films can be minted from the retired plays

// Parameters:
//
// matchID: the ID of the match to be retired entirely

transaction(matchID: UInt32) {

    // local variable for the admin reference
    let adminRef: &LeagueHeros.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the admin resource
        self.adminRef = acct.borrow<&LeagueHeros.Admin>(from: /storage/LeagueHerosAdmin)
            ?? panic("No admin resource in storage")
    }

    execute {

        // borrow a reference to the specified match
        let matchRef = self.adminRef.borrowMatch(matchID: matchID)

        // retire all the plays permenantely
        matchRef.retireAll()
    }
}