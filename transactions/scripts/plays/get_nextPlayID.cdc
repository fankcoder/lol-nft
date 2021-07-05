import League from 0xNFTADDRESS

// This script reads the public nextPlayID from the League contract and
// returns that number to the caller

// Returns: UInt32
// the nextPlayID field in League contract

pub fun main(): UInt32 {

    log(League.nextPlayID)

    return League.nextPlayID
}