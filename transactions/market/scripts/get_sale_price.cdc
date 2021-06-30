import Market from 0xMARKETADDRESS

// This script gets the price of a film in an account's sale collection
// by looking up its unique ID.

// Parameters:
//
// sellerAddress: The Flow Address of the account whose sale collection needs to be read
// filmID: The unique ID for the film whose data needs to be read

// Returns: UFix64
// The price of film with specified ID on sale

pub fun main(sellerAddress: Address, filmID: UInt64): UFix64 {

    let acct = getAccount(sellerAddress)

    let collectionRef = acct.getCapability(/public/topshotSaleCollection).borrow<&{Market.SalePublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getPrice(tokenID: UInt64(filmID))!
}