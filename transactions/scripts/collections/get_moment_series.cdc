import League from 0xTOPSHOTADDRESS

// This script gets the schedule associated with a moment
// in a collection by getting a reference to the moment
// and then looking up its schedule

// Parameters:
//
// account: The Flow Address of the account whose moment data needs to be read
// id: The unique ID for the moment whose data needs to be read

// Returns: UInt32
// The schedule associated with a moment with a specified ID

pub fun main(account: Address, id: UInt64): UInt32 {

    let collectionRef = getAccount(account).getCapability(/public/FilmCollection)
        .borrow<&{League.FilmCollectionPublic}>()
        ?? panic("Could not get public moment collection reference")

    let token = collectionRef.borrowFilm(id: id)
        ?? panic("Could not borrow a reference to the specified moment")

    let data = token.data

    return League.getMatchSeries(matchID: data.matchID)!
}