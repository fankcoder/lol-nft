import League from 0xNFTADDRESS

// This script reads the current number of moments that have been minted
// from the League contract and returns that number to the caller

// Returns: UInt64
// Number of moments minted from League contract

pub fun main(): UInt64 {

    return League.totalSupply
}