import LeagueHeros from "../../../contracts/LeagueHeros.cdc"

// This script gets the serial number of a moment
// by borrowing a reference to the moment 
// and returning its serial number

// Parameters:
//
// account: The Flow Address of the account whose moment data needs to be read
// id: The unique ID for the moment whose data needs to be read

// Returns: UInt32
// The serialNumber associated with a moment with a specified ID

pub fun main(account: Address, id: UInt64): String {

    let collectionRef = getAccount(account).getCapability(/public/FilmCollection)
        .borrow<&{LeagueHeros.FilmCollectionPublic}>()
        ?? panic("Could not get public moment collection reference")

    let token = collectionRef.borrowFilm(id: id)
        ?? panic("Could not borrow a reference to the specified moment")

    let data = token.data

    return data.ipfs
}