import League from 0xTOPSHOTADDRESS

// This script gets the matchName of a match with specified matchID

// Parameters:
//
// matchID: The unique ID for the match whose data needs to be read

// Returns: String
// Name of match with specified matchID

pub fun main(matchID: UInt32): String {

    let name = League.getMatchName(matchID: matchID)
        ?? panic("Could not find the specified match")
        
    return name
}