import League from 0xNFTADDRESS

// This script gets the match name associated with a moment
// in a collection by getting a reference to the moment
// and then looking up its name

// Parameters:
//
// account: The Flow Address of the account whose moment data needs to be read
// id: The unique ID for the moment whose data needs to be read

// Returns: String
// The match name associated with a moment with a specified ID

pub fun main(account: Address, id: UInt64): String {

    // borrow a public reference to the owner's moment collection 
    let collectionRef = getAccount(account).getCapability(/public/FilmCollection)
        .borrow<&{League.FilmCollectionPublic}>()
        ?? panic("Could not get public moment collection reference")

    // borrow a reference to the specified moment in the collection
    let token = collectionRef.borrowFilm(id: id)
        ?? panic("Could not borrow a reference to the specified moment")

    let data = token.data

    return League.getMatchName(matchID: data.matchID)!
}