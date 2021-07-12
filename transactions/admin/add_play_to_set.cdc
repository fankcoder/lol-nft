import LeagueHeros from "../../contracts/LeagueHeros.cdc"

// This transaction is how a Top Shot admin adds a created play to a match

// Parameters:
//
// matchID: the ID of the match to which a created play is added
// playID: the ID of the play being added

transaction(matchID: UInt32, playID: UInt32) {

    // Local variable for the topshot Admin object
    let adminRef: &LeagueHeros.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&LeagueHeros.Admin>(from: /storage/LeagueHerosAdmin)
            ?? panic("Could not borrow a reference to the Admin resource")
    }

    execute {
        
        // Borrow a reference to the match to be added to
        let matchRef = self.adminRef.borrowMatch(matchID: matchID)

        // Add the specified play ID
        matchRef.addPlay(playID: playID)
    }

    post {

        LeagueHeros.getPlaysInMatch(matchID: matchID)!.contains(playID):
            "match does not contain playID"
    }
}