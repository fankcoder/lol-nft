import League from 0xNFTADDRESS

// This script returns an array of all the plays 
// that have ever been created for Top Shot

// Returns: [League.Play]
// array of all plays created for Topshot

pub fun main(): [League.Play] {

    return League.getAllPlays()
}