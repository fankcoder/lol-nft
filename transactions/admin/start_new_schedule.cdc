import LeagueHeros from "../../contracts/LeagueHeros.cdc"

// This transaction is for an Admin to start a new Top Shot schedule

transaction {

    // Local variable for the topshot Admin object
    let adminRef: &LeagueHeros.Admin
    let currentSchedule: UInt32

    prepare(acct: AuthAccount) {

        // borrow a reference to the Admin resource in storage
        self.adminRef = acct.borrow<&LeagueHeros.Admin>(from: /storage/LeagueHerosAdmin)
            ?? panic("No admin resource in storage")

        self.currentSchedule = LeagueHeros.currentSchedule
    }

    execute {
        
        // Increment the schedule number
        self.adminRef.startNewSchedule()
    }

    post {
    
        LeagueHeros.currentSchedule == self.currentSchedule + 1 as UInt32:
            "new schedule not started"
    }
}
 