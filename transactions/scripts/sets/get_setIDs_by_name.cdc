import LeagueHeros from "../../../contracts/LeagueHeros.cdc"

// This script returns an array of the matchIDs
// that have the specified name

// Parameters:
//
// matchName: The name of the match whose data needs to be read

// Returns: [UInt32]
// Array of matchIDs that have specified match name

pub fun main(matchName: String): [UInt32] {

    let ids = LeagueHeros.getMatchIDsByName(matchName: matchName)
        ?? panic("Could not find the specified match name")

    return ids
}