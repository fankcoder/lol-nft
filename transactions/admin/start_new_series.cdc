import League from 0xTOPSHOTADDRESS

// This transaction is for an Admin to start a new Top Shot schedule

transaction {

    // Local variable for the topshot Admin object
    let adminRef: &League.Admin
    let currentSeries: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&League.Admin>(from: /storage/LeagueAdmin)
            ?? panic("No admin resource in storage")

        self.currentSeries = League.currentSeries
    }

    execute {
        
        // Increment the schedule number
        self.adminRef.startNewSeries()
    }

    post {
    
        League.currentSeries == self.currentSeries + 1 as UInt32:
            "new schedule not started"
    }
}
 