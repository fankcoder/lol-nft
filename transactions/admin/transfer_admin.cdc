import League from 0xTOPSHOTADDRESS
import TopshotAdminReceiver from 0xADMINRECEIVERADDRESS

// this transaction takes a League Admin resource and
// saves it to the account storage of the account
// where the contract is deployed

transaction {

    // Local variable for the topshot Admin object
    let adminRef: @League.Admin

    prepare(acct: AuthAccount) {

        self.adminRef <- acct.load<@League.Admin>(from: /storage/LeagueAdmin)
            ?? panic("No topshot admin in storage")
    }

    execute {

        TopshotAdminReceiver.storeAdmin(newAdmin: <-self.adminRef)
        
    }
}