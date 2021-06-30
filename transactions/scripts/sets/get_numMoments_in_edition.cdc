import League from 0xTOPSHOTADDRESS

// This script returns the number of specified moments that have been
// minted for the specified edition

// Parameters:
//
// matchID: The unique ID for the match whose data needs to be read
// playID: The unique ID for the play whose data needs to be read

// Returns: UInt32
// number of moments with specified playID minted for a match with specified matchID

pub fun main(matchID: UInt32, playID: UInt32): UInt32 {

    let numFilms = League.getNumFilmsInEdition(matchID: matchID, playID: playID)
        ?? panic("Could not find the specified edition")

    return numFilms
}