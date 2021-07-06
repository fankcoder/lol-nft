package contracts_test

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/fankcoder/lol-nft/lib/go/contracts"
)

var addrA = "0A"
var addrB = "0B"
var addrC = "0C"

func TestLeagueHerosContract(t *testing.T) {
	contract := contracts.GenerateLeagueHerosContract(addrA)
	assert.NotNil(t, contract)
}
