import League from 0xNFTADDRESS

// This transaction locks a match so that new plays can no longer be added to it

// Parameters:
//
// matchID: the ID of the match to be locked

transaction(matchID: UInt32) {

    // local variable for the admin resource
    let adminRef: &League.Admin

    prepare(acct: AuthAccount) {
        // borrow a reference to the admin resource
        self.adminRef = acct.borrow<&League.Admin>(from: /storage/LeagueAdmin)
            ?? panic("No admin resource in storage")
    }

    execute {
        // borrow a reference to the Match
        let matchRef = self.adminRef.borrowMatch(matchID: matchID)

        // lock the match permanently
        matchRef.lock()
    }

    post {
        
        League.isMatchLocked(matchID: matchID)!:
            "Match did not lock"
    }
}