package contracts

//go:generate go run github.com/kevinburke/go-bindata/go-bindata -prefix ../../../contracts -o internal/assets/assets.go -pkg assets -nometadata -nomemcopy ../../../contracts

import (
	"strings"
)

const (
	leagueherosFile                = "LeagueHeros.cdc"
	defaultNonFungibleTokenAddress = "NFTADDRESS"
	defaultFungibleTokenAddress    = "FUNGIBLETOKENADDRESS"
)

// GenerateLeagueHerosContract returns a copy
// of the LeagueHeros contract with the import addresses updated
func GenerateLeagueHerosContract(nftAddr string) []byte {

	// topShotCode := assets.MustAssetString(leagueherosFile)
	topShotCode, _ := DownloadFile("https://raw.githubusercontent.com/fankcoder/lol-nft/master/contracts/LeagueHeros.cdc")

	codeWithNFTAddr := strings.ReplaceAll(topShotCode, defaultNonFungibleTokenAddress, nftAddr)

	return []byte(codeWithNFTAddr)
}
