import FungibleToken from 0xFUNGIBLETOKENADDRESS
import League from 0xTOPSHOTADDRESS
import LeagueMarketV2 from 0xMARKETV2ADDRESS

// This transaction creates a sale collection and stores it in the signer's account
// It does not put an NFT up for sale

// Parameters
// 
// beneficiaryAccount: the Flow address of the account where a cut of the purchase will be sent
// cutPercentage: how much in percentage the beneficiary will receive from the sale

transaction(tokenReceiverPath: PublicPath, beneficiaryAccount: Address, cutPercentage: UFix64) {
    prepare(acct: AuthAccount) {
        let ownerCapability = acct.getCapability<&AnyResource{FungibleToken.Receiver}>(tokenReceiverPath)

        let beneficiaryCapability = getAccount(beneficiaryAccount).getCapability<&AnyResource{FungibleToken.Receiver}>(tokenReceiverPath)

        let ownerCollection = acct.link<&League.Collection>(/private/FilmCollection, target: /storage/FilmCollection)!

        let collection <- LeagueMarketV2.createSaleCollection(ownerCollection: ownerCollection, ownerCapability: ownerCapability, beneficiaryCapability: beneficiaryCapability, cutPercentage: cutPercentage)
        
        acct.save(<-collection, to: LeagueMarketV2.marketStoragePath)
        
        acct.link<&LeagueMarketV2.SaleCollection{LeagueMarketV2.SalePublic}>(LeagueMarketV2.marketPublicPath, target: LeagueMarketV2.marketStoragePath)
    }
}
