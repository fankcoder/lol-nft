import League from 0xTOPSHOTADDRESS

// This transaction adds multiple plays to a match
		
// Parameters:
//
// matchID: the ID of the match to which multiple plays are added
// plays: an array of play IDs being added to the match

transaction(matchID: UInt32, plays: [UInt32]) {

    // Local variable for the topshot Admin object
    let adminRef: &League.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&League.Admin>(from: /storage/LeagueAdmin)!
    }

    execute {

        // borrow a reference to the match to be added to
        let matchRef = self.adminRef.borrowMatch(matchID: matchID)

        // Add the specified play IDs
        matchRef.addPlays(playIDs: plays)
    }
}