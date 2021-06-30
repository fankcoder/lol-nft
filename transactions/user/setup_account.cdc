import League from 0xTOPSHOTADDRESS

// This transaction matchs up an account to use Top Shot
// by storing an empty film collection and creating
// a public capability for it

transaction {

    prepare(acct: AuthAccount) {

        // First, check to see if a film collection already exists
        if acct.borrow<&League.Collection>(from: /storage/FilmCollection) == nil {

            // create a new League Collection
            let collection <- League.createEmptyCollection() as! @League.Collection

            // Put the new Collection in storage
            acct.save(<-collection, to: /storage/FilmCollection)

            // create a public capability for the collection
            acct.link<&{League.FilmCollectionPublic}>(/public/FilmCollection, target: /storage/FilmCollection)
        }
    }
}