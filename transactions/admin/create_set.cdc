import League from 0xNFTADDRESS

// This transaction is for the admin to create a new match resource
// and store it in the top shot smart contract

// Parameters:
//
// matchName: the name of a new Match to be created

transaction(matchName: String) {
    
    // Local variable for the topshot Admin object
    let adminRef: &League.Admin
    let currMatchID: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&League.Admin>(from: /storage/LeagueAdmin)
            ?? panic("Could not borrow a reference to the Admin resource")
        self.currMatchID = League.nextMatchID;
    }

    execute {
        
        // Create a match with the specified name
        self.adminRef.createMatch(name: matchName)
    }

    post {
        
        League.getMatchName(matchID: self.currMatchID) == matchName:
          "Could not find the specified match"
    }
}