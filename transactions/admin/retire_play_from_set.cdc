import League from 0xTOPSHOTADDRESS

// This transaction is for retiring a play from a match, which
// makes it so that films can no longer be minted from that edition

// Parameters:
// 
// matchID: the ID of the match in which a play is to be retired
// playID: the ID of the play to be retired

transaction(matchID: UInt32, playID: UInt32) {
    
    // local variable for storing the reference to the admin resource
    let adminRef: &League.Admin

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&League.Admin>(from: /storage/LeagueAdmin)
            ?? panic("No admin resource in storage")
    }

    execute {

        // borrow a reference to the specified match
        let matchRef = self.adminRef.borrowMatch(matchID: matchID)

        // retire the play
        matchRef.retirePlay(playID: playID)
    }

    post {
        
        self.adminRef.borrowMatch(matchID: matchID).retired[playID]!:
            "play is not retired"
    }
}