import League from 0xTOPSHOTADDRESS

// This script gets the matchID associated with a moment
// in a collection by getting a reference to the moment
// and then looking up its matchID

// Parameters:
//
// account: The Flow Address of the account whose moment data needs to be read
// id: The unique ID for the moment whose data needs to be read

// Returns: UInt32
// The matchID associated with a moment with a specified ID

pub fun main(account: Address, id: UInt64): UInt32 {

    // borrow a public reference to the owner's moment collection 
    let collectionRef = getAccount(account).getCapability(/public/FilmCollection)
        .borrow<&{League.FilmCollectionPublic}>()
        ?? panic("Could not get public moment collection reference")

    // borrow a reference to the specified moment in the collection
    let token = collectionRef.borrowFilm(id: id)
        ?? panic("Could not borrow a reference to the specified moment")

    let data = token.data

    return data.matchID
}