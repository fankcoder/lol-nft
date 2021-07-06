import NonFungibleToken from 0xf8d6e0586b0a20c7

pub contract LeagueHeros: NonFungibleToken {
    // Emitted when the LeagueHeros contract is created
    pub event ContractInitialized()

    // Emitted when a new Play struct is created
    pub event PlayCreated(id: UInt32, metadata: {String:String})
    // Emitted when a new Hero struct is created
    pub event HeroCreated(id: UInt32, metadata: {String:String})
    // Emitted when a new schedule has been triggered by an admin
    pub event NewScheduleStarted(newCurrentSchedule: UInt32)

    // Events for Match-Related actions
    //
    // Emitted when a new Match is created
    pub event MatchCreated(matchID: UInt32, schedule: UInt32)
    // Emitted when a new Play is added to a Match
    pub event PlayAddedToMatch(matchID: UInt32, playID: UInt32)
    // Emitted when a Play is retired from a Match and cannot be used to mint
    pub event PlayRetiredFromMatch(matchID: UInt32, playID: UInt32, numFilms: UInt32)
    // Emitted when a Match is locked, meaning Plays cannot be added
    pub event MatchLocked(matchID: UInt32)
    // Emitted when a Film is minted from a Match
    pub event FilmMinted(filmID: UInt64, playID: UInt32, matchID: UInt32, serialNumber: UInt32)

    // Emitted when a film is withdrawn from a Collection
    pub event Withdraw(id: UInt64, from: Address?)
    // Emitted when a film is deposited into a Collection
    pub event Deposit(id: UInt64, to: Address?)

    // Emitted when a Film is destroyed
    pub event FilmDestroyed(id: UInt64)

    // -----------------------------------------------------------------------
    // LeagueHeros contract-level fields.
    // These contain actual values that are stored in the smart contract.
    // -----------------------------------------------------------------------

    // Schedule that this Game Match belongs to.
    // Many Matchs can exist at a time, but only one schedule.
    pub var currentSchedule: UInt32

    // Variable size dictionary of Play structs
    access(self) var playDatas: {UInt32: Play}

    // Variable size dictionary of Play structs
    access(self) var heroDatas: {UInt32: Hero}

    // Variable size dictionary of MatchData structs
    access(self) var matchDatas: {UInt32: MatchData}

    // Variable size dictionary of Match resources
    access(self) var matchs: @{UInt32: Match}

    // The ID that is used to create Plays. 
    // Every time a Play is created, playID is assigned 
    // to the new Play's ID and then is incremented by 1.
    pub var nextPlayID: UInt32

    // The ID that is used to create Heros. 
    // Every time a Hero is created, Hero is assigned 
    // to the new Hero's ID and then is incremented by 1.
    pub var nextHeroID: UInt32

    // The ID that is used to create Game Matchs. Every time a Game Match is created
    // matchID is assigned to the new match's ID and then is incremented by 1.
    pub var nextMatchID: UInt32

    // The total number of LeagueHeros Film NFTs that have been created
    // Because NFTs can be destroyed, it doesn't necessarily mean that this
    // reflects the total number of NFTs in existence, just the number that
    // have been minted to date. Also used as global film IDs for minting.
    pub var totalSupply: UInt64

    // Play is a Struct that holds metadata associated with a specific lol match player
    // Film NFTs will all reference a single play as the owner of
    // its metadata. The plays are publicly accessible, so anyone can
    // read the metadata associated with a specific play ID
    //
    pub struct Play {

        // The unique ID for the Play
        pub let playID: UInt32

        // Stores all the metadata about the play as a string mapping
        // This is not the long term way NFT metadata will be stored. It's a temporary
        // construct while we figure out a better way to do metadata.
        //
        access(contract) let metadata: {String: String}

        init(metadata: {String: String}) {
            pre {
                metadata.length != 0: "New Play metadata cannot be empty"
            }
            self.playID = LeagueHeros.nextPlayID
            self.metadata = metadata

            // Increment the ID so that it isn't used again
            LeagueHeros.nextPlayID = LeagueHeros.nextPlayID + UInt32(1)

            emit PlayCreated(id: self.playID, metadata: metadata)
        }
    }

    // Hero is a  Struct that holds metadata associated with a specific lol hero
    pub struct Hero {

        // The unique ID for the Hero
        pub let heroID: UInt32

        // Stores all the metadata about the play as a string mapping
        // This is not the long term way NFT metadata will be stored. It's a temporary
        // construct while we figure out a better way to do metadata.
        //
        access(contract) let metadata: {String: String}

        init(metadata: {String: String}) {
            pre {
                metadata.length != 0: "New Hero metadata cannot be empty"
            }
            self.heroID = LeagueHeros.nextHeroID
            self.metadata = metadata

            // Increment the ID so that it isn't used again
            LeagueHeros.nextHeroID = LeagueHeros.nextHeroID + UInt32(1)

            emit HeroCreated(id: self.heroID, metadata: metadata)
        }
    }

    // A Match is a grouping of Plays that have occured in the real world
    // A Play can exist in multiple different matchs.
    // 
    // MatchData is a struct that is stored in a field of the contract.
    // Anyone can query the constant information
    // Only the admin has the ability 
    // to modify any data in the private Match resource.
    //
    pub struct MatchData {

        // Unique ID for the Match
        pub let matchID: UInt32

        // Name of the Match
        pub let name: String

        // Schedule that this a series of lol game match.
        // Schedule is a concept that indicates a group of Matchs through time.
        // Many Matchs can exist at a time, but only one schedule.
        pub let schedule: UInt32

        init(name: String) {
            pre {
                name.length > 0: "New Match name cannot be empty"
            }
            self.matchID = LeagueHeros.nextMatchID
            self.name = name
            self.schedule = LeagueHeros.currentSchedule

            // Increment the matchID so that it isn't used again
            LeagueHeros.nextMatchID = LeagueHeros.nextMatchID + UInt32(1)

            emit MatchCreated(matchID: self.matchID, schedule: self.schedule)
        }
    }

    // Match is a resource type that contains the functions to add and remove
    // Plays from a match and mint Films.
    pub resource Match {

        // Unique ID for the match
        pub let matchID: UInt32

        // Array of plays that are a part of this match.
        pub var plays: [UInt32]

        // When a Play is retired, this is match to true and cannot be changed.
        access(contract) var retired: {UInt32: Bool}

        // When a Match is created, it is default unlocked 
        // and Plays are allowed to be added to it.
        // When a match is locked, Plays cannot be added.
        // If a Match is locked, Plays cannot be added, but
        // Films can still be minted from Plays
        // that exist in the Match.
        pub var locked: Bool

        // Mapping of Play IDs that indicates the number of Films 
        // that have been minted for specific Plays in this Match.
        // When a Film is minted, this value is stored in the Film to
        // show its place in the Match, eg. 13 of 60.
        access(contract) var numberMintedPerPlay: {UInt32: UInt32}

        init(name: String) {
            self.matchID = LeagueHeros.nextMatchID
            self.plays = []
            self.retired = {}
            self.locked = false
            self.numberMintedPerPlay = {}

            // Create a new MatchData for this Match and store it in contract storage
            LeagueHeros.matchDatas[self.matchID] = MatchData(name: name)
        }

        // addPlay adds a play to the match
        //
        // Parameters: playID: The ID of the Play that is being added
        //
        // Pre-Conditions:
        // The Play needs to be an existing play
        // The Match needs to be not locked
        // The Play can't have already been added to the Match
        //
        pub fun addPlay(playID: UInt32) {
            pre {
                LeagueHeros.playDatas[playID] != nil: "Cannot add the Play to Match: Play doesn't exist."
                !self.locked: "Cannot add the play to the Match after the match has been locked."
                self.numberMintedPerPlay[playID] == nil: "The play has already beed added to the match."
            }

            // Add the Play to the array of Plays
            self.plays.append(playID)

            // Open the Play up for minting
            self.retired[playID] = false

            // Initialize the Film count to zero
            self.numberMintedPerPlay[playID] = 0

            emit PlayAddedToMatch(matchID: self.matchID, playID: playID)
        }

        // addPlays adds multiple Plays to the Match
        //
        // Parameters: playIDs: The IDs of the Plays that are being added
        //                      as an array
        //
        pub fun addPlays(playIDs: [UInt32]) {
            for play in playIDs {
                self.addPlay(playID: play)
            }
        }

        // retirePlay retires a Play from the Match so that it can't mint new Films
        //
        // Parameters: playID: The ID of the Play that is being retired
        //
        // Pre-Conditions:
        // The Play is part of the Match and not retired (available for minting).
        // 
        pub fun retirePlay(playID: UInt32) {
            pre {
                self.retired[playID] != nil: "Cannot retire the Play: Play doesn't exist in this match!"
            }

            if !self.retired[playID]! {
                self.retired[playID] = true

                emit PlayRetiredFromMatch(matchID: self.matchID, playID: playID, numFilms: self.numberMintedPerPlay[playID]!)
            }
        }

        // retireAll retires all the plays in the Match
        // Afterwards, none of the retired Plays will be able to mint new Films
        //
        pub fun retireAll() {
            for play in self.plays {
                self.retirePlay(playID: play)
            }
        }

        // lock() locks the Match so that no more Plays can be added to it
        //
        // Pre-Conditions:
        // The Match should not be locked
        pub fun lock() {
            if !self.locked {
                self.locked = true
                emit MatchLocked(matchID: self.matchID)
            }
        }

        // mintFilm mints a new Film and returns the newly minted Film
        // 
        // Parameters: playID: The ID of the Play that the Film references
        //
        // Returns: The NFT that was minted
        // 
        pub fun mintFilm(playID: UInt32, ipfs: String): @NFT {
            pre {
                self.retired[playID] != nil: "Cannot mint the film: This play doesn't exist."
                !self.retired[playID]!: "Cannot mint the film from this play: This play has been retired."
            }

            // Gets the number of Films that have been minted for this Play
            // to use as this Film's serial number
            let numInPlay = self.numberMintedPerPlay[playID]!

            // Mint the new film
            let newFilm: @NFT <- create NFT(serialNumber: numInPlay + UInt32(1),
                                              playID: playID,
                                              matchID: self.matchID,
                                              ipfs: ipfs
                                              )

            // Increment the count of Films minted for this Play
            self.numberMintedPerPlay[playID] = numInPlay + UInt32(1)

            return <-newFilm
        }

        // batchMintFilm mints an arbitrary quantity of Films
        // and returns them as a Collection
        //
        // Parameters: playID: the ID of the Play that the Films are minted for
        //             quantity: The quantity of Films to be minted
        //
        // Returns: Collection object that contains all the Films that were minted
        //
        pub fun batchMintFilm(playID: UInt32, quantity: UInt64, ipfs: String): @Collection {
            let newCollection <- create Collection()

            var i: UInt64 = 0
            while i < quantity {
                newCollection.deposit(token: <-self.mintFilm(playID: playID, ipfs:ipfs))
                i = i + UInt64(1)
            }

            return <-newCollection
        }
    }

    pub struct FilmData {

        // The ID of the Match that the Film comes from
        pub let matchID: UInt32

        // The ID of the Play that the Film references
        pub let playID: UInt32

        // The place in the edition that this Film was minted
        // Otherwise know as the serial number
        pub let serialNumber: UInt32
        //
        pub let ipfs: String

        init(matchID: UInt32, playID: UInt32, serialNumber: UInt32,ipfs : String) {
            self.matchID = matchID
            self.playID = playID
            self.serialNumber = serialNumber
            self.ipfs = ipfs
        }

    }

    // The Film NFTs resource
    //
    pub resource NFT: NonFungibleToken.INFT {

        // Global unique film ID
        pub let id: UInt64

        // Struct of Film metadata
        pub let data: FilmData

        init(serialNumber: UInt32, playID: UInt32, matchID: UInt32, ipfs: String) {
            // Increment the global Film IDs
            LeagueHeros.totalSupply = LeagueHeros.totalSupply + UInt64(1)

            self.id = LeagueHeros.totalSupply

            // Match the metadata struct
            self.data = FilmData(matchID: matchID, playID: playID, serialNumber: serialNumber, ipfs:ipfs)

            emit FilmMinted(filmID: self.id, playID: playID, matchID: self.data.matchID, serialNumber: self.data.serialNumber)
        }

        // Emit an  Film destroyed event
        destroy() {
            emit FilmDestroyed(id: self.id)
        }
    }

    // Admin function
    pub resource Admin {

        // createPlay creates a new Play struct 
        // and stores it in the Plays dictionary in the LeagueHeros smart contract
        // Parameters: metadata: A dictionary mapping metadata titles to their data
        // Returns: the ID of the new Play object
        //
        pub fun createPlay(metadata: {String: String}): UInt32 {
            // Create the new Play
            var newPlay = Play(metadata: metadata)
            let newID = newPlay.playID

            // Store it in the contract storage
            LeagueHeros.playDatas[newID] = newPlay

            return newID
        }

        // createHero creates a new Hero struct 
        // and stores it in the Heros dictionary in the LeagueHeros smart contract
        // Parameters: metadata: A dictionary mapping metadata titles to their data
        // Returns: the ID of the new Hero object
        //
        pub fun createHero(metadata: {String: String}): UInt32 {
            // Create the new Hero
            var newHero = Hero(metadata: metadata)
            let newID = newHero.heroID

            // Store it in the contract storage
            LeagueHeros.heroDatas[newID] = newHero

            return newID
        }

        // createMatch creates a new Match resource and stores it
        // in the matchs mapping in the LeagueHeros contract
        //
        // Parameters: name: The name of the Match
        //
        pub fun createMatch(name: String) {
            // Create the new Match
            var newMatch <- create Match(name: name)

            // Store it in the matchs mapping field
            LeagueHeros.matchs[newMatch.matchID] <-! newMatch
        }

        // borrowMatch returns a reference to a match in the LeagueHeros
        // contract so that the admin can call methods on it
        //
        // Parameters: matchID: The ID of the Match that you want to
        // get a reference to
        //
        // Returns: A reference to the Match with all of the fields
        // and methods exposed
        //
        pub fun borrowMatch(matchID: UInt32): &Match {
            pre {
                LeagueHeros.matchs[matchID] != nil: "Cannot borrow Match: The Match doesn't exist"
            }
            
            // Get a reference to the Match and return it
            // use `&` to indicate the reference to the object and type
            return &LeagueHeros.matchs[matchID] as &Match
        }

        // startNewSchedule ends the current schedule by incrementing
        // the schedule number, meaning that Films minted after this
        // will use the new schedule number
        //
        // Returns: The new schedule number
        //
        pub fun startNewSchedule(): UInt32 {
            // End the current schedule and start a new one
            // by incrementing the LeagueHeros schedule number
            LeagueHeros.currentSchedule = LeagueHeros.currentSchedule + UInt32(1)

            emit NewScheduleStarted(newCurrentSchedule: LeagueHeros.currentSchedule)

            return LeagueHeros.currentSchedule
        }

        // createNewAdmin creates a new Admin resource
        //
        pub fun createNewAdmin(): @Admin {
            return <-create Admin()
        }
    }

    // This is the interface that users can cast their Film Collection as
    // to allow others to deposit Films into their Collection. It also allows for reading
    // the IDs of Films in the Collection.
    pub resource interface FilmCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowFilm(id: UInt64): &LeagueHeros.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id): 
                    "Cannot borrow Film reference: The ID of the returned reference is incorrect"
            }
        }
    }

    // Collection is a resource that every user who owns NFTs 
    // will store in their account to manage their NFTS
    //
    pub resource Collection: FilmCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic { 
        // Dictionary of Film conforming tokens
        // NFT is a resource type with a UInt64 ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init() {
            self.ownedNFTs <- {}
        }

        // withdraw removes an Film from the Collection and moves it to the caller
        //
        // Parameters: withdrawID: The ID of the NFT 
        // that is to be removed from the Collection
        //
        // returns: @NonFungibleToken.NFT the token that was withdrawn
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {

            // Remove the nft from the Collection
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot withdraw: Film does not exist in the collection")

            emit Withdraw(id: token.id, from: self.owner?.address)
            
            // Return the withdrawn token
            return <-token
        }

        // batchWithdraw withdraws multiple tokens and returns them as a Collection
        //
        // Parameters: ids: An array of IDs to withdraw
        //
        // Returns: @NonFungibleToken.Collection: A collection that contains
        //                                        the withdrawn films
        //
        pub fun batchWithdraw(ids: [UInt64]): @NonFungibleToken.Collection {
            // Create a new empty Collection
            var batchCollection <- create Collection()
            
            // Iterate through the ids and withdraw them from the Collection
            for id in ids {
                batchCollection.deposit(token: <-self.withdraw(withdrawID: id))
            }
            
            // Return the withdrawn tokens
            return <-batchCollection
        }

        // deposit takes a Film and adds it to the Collections dictionary
        //
        // Paramters: token: the NFT to be deposited in the collection
        //
        pub fun deposit(token: @NonFungibleToken.NFT) {
            
            // Cast the deposited token as a LeagueHeros NFT to make sure
            // it is the correct type
            let token <- token as! @LeagueHeros.NFT

            // Get the token's ID
            let id = token.id

            // Add the new token to the dictionary
            let oldToken <- self.ownedNFTs[id] <- token

            // Only emit a deposit event if the Collection 
            // is in an account's storage
            if self.owner?.address != nil {
                emit Deposit(id: id, to: self.owner?.address)
            }

            // Destroy the empty old token that was "removed"
            destroy oldToken
        }

        // batchDeposit takes a Collection object as an argument
        // and deposits each contained NFT into this Collection
        pub fun batchDeposit(tokens: @NonFungibleToken.Collection) {

            // Get an array of the IDs to be deposited
            let keys = tokens.getIDs()

            // Iterate through the keys in the collection and deposit each one
            for key in keys {
                self.deposit(token: <-tokens.withdraw(withdrawID: key))
            }

            // Destroy the empty Collection
            destroy tokens
        }

        // getIDs returns an array of the IDs that are in the Collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // borrowNFT Returns a borrowed reference to a Film in the Collection
        // so that the caller can read its ID
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        //
        // Note: This only allows the caller to read the ID of the NFT,
        // not any LeagueHeros specific data. Please use borrowFilm to 
        // read Film data.
        //
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        // borrowFilm returns a borrowed reference to a Film
        // so that the caller can read data and call methods from it.
        // They can use this to read its matchID, playID, serialNumber,
        // or any of the matchData or Play data associated with it by
        // getting the matchID or playID and reading those fields from
        // the smart contract.
        //
        // Parameters: id: The ID of the NFT to get the reference for
        //
        // Returns: A reference to the NFT
        pub fun borrowFilm(id: UInt64): &LeagueHeros.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &LeagueHeros.NFT
            } else {
                return nil
            }
        }

        // If a transaction destroys the Collection object,
        // All the NFTs contained within are also destroyed!
        // Much like when Damian Lillard destroys the hopes and
        // dreams of the entire city of Houston.
        //
        destroy() {
            LeagueHeros.totalSupply = LeagueHeros.totalSupply - UInt64(1)
            destroy self.ownedNFTs
        }
    }

    // -----------------------------------------------------------------------
    // LeagueHeros contract-level function definitions
    // -----------------------------------------------------------------------

    // createEmptyCollection creates a new, empty Collection object so that
    // a user can store it in their account storage.
    // Once they have a Collection in their storage, they are able to receive
    // Films in transactions.
    //
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <-create LeagueHeros.Collection()
    }

    // getAllPlays returns all the plays in LeagueHeros
    //
    // Returns: An array of all the plays that have been created
    pub fun getAllPlays(): [LeagueHeros.Play] {
        return LeagueHeros.playDatas.values
    }

    // getAllHeros returns all the heros in LeagueHeros
    //
    // Returns: An array of all the heros that have been created
    pub fun getAllHeros(): [LeagueHeros.Hero] {
        return LeagueHeros.heroDatas.values
    }

    // getPlayMetaData returns all the metadata associated with a specific Play
    // 
    // Parameters: playID: The id of the Play that is being searched
    //
    // Returns: The metadata as a String to String mapping optional
    pub fun getPlayMetaData(playID: UInt32): {String: String}? {
        return self.playDatas[playID]?.metadata
    }

    // getHeroMetaData returns all the metadata associated with a specific Hero
    // 
    // Parameters: heroID: The id of the Hero that is being searched
    //
    // Returns: The metadata as a String to String mapping optional
    pub fun getHeroMetaData(heroID: UInt32): {String: String}? {
        return self.heroDatas[heroID]?.metadata
    }

    // getPlayMetaDataByField returns the metadata associated with a 
    //                        specific field of the metadata
    // 
    // Parameters: playID: The id of the Play that is being searched
    //             field: The field to search for
    //
    // Returns: The metadata field as a String Optional
    pub fun getPlayMetaDataByField(playID: UInt32, field: String): String? {
        // Don't force a revert if the playID or field is invalid
        if let play = LeagueHeros.playDatas[playID] {
            return play.metadata[field]
        } else {
            return nil
        }
    }

    // getMatchName returns the name that the specified Match
    //            is associated with.
    // 
    // Parameters: matchID: The id of the Match that is being searched
    //
    // Returns: The name of the Match
    pub fun getMatchName(matchID: UInt32): String? {
        // Don't force a revert if the matchID is invalid
        return LeagueHeros.matchDatas[matchID]?.name
    }

    // getMatchSchedule returns the schedule that the specified Match
    //              is associated with.
    // 
    // Parameters: matchID: The id of the Match that is being searched
    //
    // Returns: The schedule that the Match belongs to
    pub fun getMatchSchedule(matchID: UInt32): UInt32? {
        // Don't force a revert if the matchID is invalid
        return LeagueHeros.matchDatas[matchID]?.schedule
    }

    // getMatchIDsByName returns the IDs that the specified Match name
    //                 is associated with.
    // 
    // Parameters: matchName: The name of the Match that is being searched
    //
    // Returns: An array of the IDs of the Match if it exists, or nil if doesn't
    pub fun getMatchIDsByName(matchName: String): [UInt32]? {
        var matchIDs: [UInt32] = []

        // Iterate through all the matchDatas and search for the name
        for matchData in LeagueHeros.matchDatas.values {
            if matchName == matchData.name {
                // If the name is found, return the ID
                matchIDs.append(matchData.matchID)
            }
        }

        // If the name isn't found, return nil
        // Don't force a revert if the matchName is invalid
        if matchIDs.length == 0 {
            return nil
        } else {
            return matchIDs
        }
    }

    // getPlaysInMatch returns the list of Play IDs that are in the Match
    // 
    // Parameters: matchID: The id of the Match that is being searched
    //
    // Returns: An array of Play IDs
    pub fun getPlaysInMatch(matchID: UInt32): [UInt32]? {
        // Don't force a revert if the matchID is invalid
        return LeagueHeros.matchs[matchID]?.plays
    }

    // Parameters: matchID: The id of the Match that is being searched
    //             playID: The id of the Play that is being searched
    //
    // Returns: Boolean indicating if the edition is retired or not
    pub fun isEditionRetired(matchID: UInt32, playID: UInt32): Bool? {
        // Don't force a revert if the match or play ID is invalid
        // Remove the match from the dictionary to get its field
        if let matchToRead <- LeagueHeros.matchs.remove(key: matchID) {

            // See if the Play is retired from this Match
            let retired = matchToRead.retired[playID]

            // Put the Match back in the contract storage
            LeagueHeros.matchs[matchID] <-! matchToRead

            // Return the retired status
            return retired
        } else {

            // If the Match wasn't found, return nil
            return nil
        }
    }

    // isMatchLocked returns a boolean that indicates if a Match
    //             is locked. If it's locked, 
    //             new Plays can no longer be added to it,
    //             but Films can still be minted from Plays the match contains.
    // 
    // Parameters: matchID: The id of the Match that is being searched
    //
    // Returns: Boolean indicating if the Match is locked or not
    pub fun isMatchLocked(matchID: UInt32): Bool? {
        // Don't force a revert if the matchID is invalid
        return LeagueHeros.matchs[matchID]?.locked
    }

    // getNumFilmsInEdition return the number of Films that have been 
    //                        minted from a certain edition.
    //
    // Parameters: matchID: The id of the Match that is being searched
    //             playID: The id of the Play that is being searched
    //
    // Returns: The total number of Films 
    //          that have been minted from an edition
    pub fun getNumFilmsInEdition(matchID: UInt32, playID: UInt32): UInt32? {
        // Don't force a revert if the Match or play ID is invalid
        // Remove the Match from the dictionary to get its field
        if let matchToRead <- LeagueHeros.matchs.remove(key: matchID) {

            // Read the numMintedPerPlay
            let amount = matchToRead.numberMintedPerPlay[playID]

            // Put the Match back into the Matchs dictionary
            LeagueHeros.matchs[matchID] <-! matchToRead

            return amount
        } else {
            // If the match wasn't found return nil
            return nil
        }
    }

    // -----------------------------------------------------------------------
    // LeagueHeros initialization function
    // -----------------------------------------------------------------------
    //
    init() {
        // Initialize contract fields
        self.currentSchedule = 0
        self.playDatas = {}
        self.heroDatas = {}
        self.matchDatas = {}
        self.matchs <- {}
        self.nextPlayID = 1
        self.nextHeroID = 1
        self.nextMatchID = 1
        self.totalSupply = 0

        // Put a new Collection in storage
        self.account.save<@Collection>(<- create Collection(), to: /storage/FilmCollection)

        // Create a public capability for the Collection
        self.account.link<&{FilmCollectionPublic}>(/public/FilmCollection, target: /storage/FilmCollection)

        // Put the Minter in storage
        self.account.save<@Admin>(<- create Admin(), to: /storage/LeagueHerosAdmin)

        emit ContractInitialized()
    }
}
 
