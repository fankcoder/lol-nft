import LeagueHeros from "../../../contracts/LeagueHeros.cdc"

// This transaction reads if a specified edition is retired

// Parameters:
//
// matchID: The unique ID for the match whose data needs to be read
// playID: The unique ID for the play whose data needs to be read

// Returns: Bool
// Whether specified match is retired

pub fun main(matchID: UInt32, playID: UInt32): Bool {

    let isRetired = LeagueHeros.isEditionRetired(matchID: matchID, playID: playID)
        ?? panic("Could not find the specified edition")
    
    return isRetired
}