package test

import (
	"regexp"
	"testing"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	emulator "github.com/onflow/flow-emulator"
	sdk "github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	sdktemplates "github.com/onflow/flow-go-sdk/templates"
	"github.com/onflow/flow-go-sdk/test"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/onflow/flow-go-sdk"
	nft_contracts "github.com/onflow/flow-nft/lib/go/contracts"
)

const (
	TransactionsRootPath  = "../../transactions"
	leagueScriptsRootPath = "../../transactions/scripts"

	LeagueHerosContractPath = "../../contracts/LeagueHeros.cdc"
	SetupAccountPath        = TransactionsRootPath + "/user/setup_account.cdc"
	CreatePlayPath          = TransactionsRootPath + "/admin/create_play.cdc"
	CreateSetPath           = TransactionsRootPath + "/admin/create_set.cdc"
	AddPlayPath             = TransactionsRootPath + "/admin/add_play_to_set.cdc"
	MintPath                = TransactionsRootPath + "/admin/mint_moment.cdc"
	LockSetPath             = TransactionsRootPath + "/admin/lock_set.cdc"
	RetirePlayALLPath       = TransactionsRootPath + "/admin/retire_all.cdc"
	StartNewSchedulePath    = TransactionsRootPath + "/admin/start_new_schedule.cdc"
	TransferPath            = TransactionsRootPath + "/user/transfer_moment.cdc"

	InspectSupplyPath        = leagueScriptsRootPath + "/get_totalSupply.cdc"
	InspectCollectionLenPath = leagueScriptsRootPath + "/collections/get_collection_length.cdc"
	GetAllPlaysLengthPath    = leagueScriptsRootPath + "/plays/get_all_plays_length.cdc"
	GetAllPlaysPath          = leagueScriptsRootPath + "/plays/get_all_plays.cdc"
	GetNextPlayIDPath        = leagueScriptsRootPath + "/plays/get_nextPlayID.cdc"
	GetPlayMetadataPath      = leagueScriptsRootPath + "/plays/get_play_metadata.cdc"
	GetSetNamePath           = leagueScriptsRootPath + "/sets/get_setName.cdc"
	GetPlaysInSetPath        = leagueScriptsRootPath + "/sets/get_plays_in_set.cdc"
	GetCurrentSchedulePath   = leagueScriptsRootPath + "/get_currentSchedule.cdc"
	GetEditionRetiredPath    = leagueScriptsRootPath + "/sets/get_edition_retired.cdc"

	typeID = 1000
)

func DeployContracts(b *emulator.Blockchain, t *testing.T) (flow.Address, flow.Address, crypto.Signer) {
	accountKeys := test.AccountKeyGenerator()

	// should be able to deploy a contract as a new account with no keys
	nftCode := loadNonFungibleToken()
	nftAddr, err := b.CreateAccount(
		nil,
		[]sdktemplates.Contract{
			{
				Name:   "NonFungibleToken",
				Source: string(nftCode),
			},
		},
	)
	require.NoError(t, err)

	_, err = b.CommitBlock()
	assert.NoError(t, err)

	// should be able to deploy a contract as a new account with one key
	// leagueAccountKey, leagueSigner := accountKeys.NewWithSigner()
	leagueAccountKey, leagueSigner := accountKeys.NewWithSigner()
	leagueCode := loadLeagueHeros(nftAddr.String())
	// leagueCode := loadleague(nftAddr.String())
	// leagueAddr, err := b.CreateAccount(
	leagueAddr, err := b.CreateAccount(
		[]*flow.AccountKey{leagueAccountKey},
		[]sdktemplates.Contract{
			{
				Name:   "LeagueHeros",
				Source: string(leagueCode),
			},
		},
	)
	assert.NoError(t, err)

	_, err = b.CommitBlock()
	assert.NoError(t, err)

	// simplify the workflow by having the contract address also be our initial test collection
	leagueSetupAccount(t, b, leagueAddr, leagueSigner, nftAddr, leagueAddr)

	return nftAddr, leagueAddr, leagueSigner
}

func leagueSetupAccount(
	t *testing.T, b *emulator.Blockchain,
	userAddress sdk.Address, userSigner crypto.Signer, nftAddr sdk.Address, leagueAddr sdk.Address,
) {
	tx := flow.NewTransaction().
		SetScript(GenerateSetupAccountScript(nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(userAddress)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, userAddress},
		[]crypto.Signer{b.ServiceKey().Signer(), userSigner},
		false,
	)
}

func createPlay(
	t *testing.T, b *emulator.Blockchain,
	nftAddr, leagueAddr flow.Address,
	leagueSigner crypto.Signer,
) {
	tx := flow.NewTransaction().
		SetScript(GenerateScript(CreatePlayPath, nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(leagueAddr)

	nameKey := cadence.NewString("Name")
	nameValue := cadence.NewString("Fank")
	nameKey2 := cadence.NewString("Name")
	nameValue2 := cadence.NewString("Lili")
	nameKey3 := cadence.NewString("Name")
	nameValue3 := cadence.NewString("virgil")
	// FankPlayID := uint32(1)
	metadata := []cadence.KeyValuePair{{Key: nameKey, Value: nameValue}}
	play := cadence.NewDictionary(metadata)

	_ = tx.AddArgument(play)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, leagueAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), leagueSigner},
		false,
	)
	tx = flow.NewTransaction().
		SetScript(GenerateScript(CreatePlayPath, nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(leagueAddr)
	metadata = []cadence.KeyValuePair{{Key: nameKey2, Value: nameValue2}}
	play = cadence.NewDictionary(metadata)

	_ = tx.AddArgument(play)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, leagueAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), leagueSigner},
		false,
	)

	tx = flow.NewTransaction().
		SetScript(GenerateScript(CreatePlayPath, nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(leagueAddr)
	metadata = []cadence.KeyValuePair{{Key: nameKey3, Value: nameValue3}}
	play = cadence.NewDictionary(metadata)

	_ = tx.AddArgument(play)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, leagueAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), leagueSigner},
		false,
	)

	length := executeScriptAndCheck(
		t,
		b,
		leagueGenerateScript(GetAllPlaysLengthPath, nftAddr.String(), leagueAddr.String()),
		nil,
	)
	assert.EqualValues(t, cadence.NewInt(3), length)

}

func createMatch(
	t *testing.T, b *emulator.Blockchain,
	nftAddr, leagueAddr flow.Address,
	leagueSigner crypto.Signer,
) {
	fiveKillSetID := uint32(1)
	tx := flow.NewTransaction().
		SetScript(GenerateScript(CreateSetPath, nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(leagueAddr)

	_ = tx.AddArgument(cadence.NewString("FiveKill"))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, leagueAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), leagueSigner},
		false,
	)

	setName := executeScriptAndCheck(
		t,
		b,
		leagueGenerateScript(GetSetNamePath, nftAddr.String(), leagueAddr.String()),
		[][]byte{jsoncdc.MustEncode(cadence.UInt32(fiveKillSetID))},
	)
	assert.EqualValues(t, cadence.NewString("FiveKill"), setName)
}

func addPlaytoMatch(
	t *testing.T, b *emulator.Blockchain,
	nftAddr, leagueAddr flow.Address,
	leagueSigner crypto.Signer,
) {
	tx := flow.NewTransaction().
		SetScript(GenerateScript(AddPlayPath, nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(leagueAddr)

	_ = tx.AddArgument(cadence.NewUInt32(1))
	_ = tx.AddArgument(cadence.NewUInt32(1))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, leagueAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), leagueSigner},
		false,
	)

	plays := executeScriptAndCheck(
		t,
		b,
		leagueGenerateScript(GetPlaysInSetPath, nftAddr.String(), leagueAddr.String()),
		[][]byte{jsoncdc.MustEncode(cadence.UInt32(1))},
	)
	assert.EqualValues(t, cadence.NewArray([]cadence.Value{cadence.NewUInt32(1)}), plays)
}

func retirePlay(
	t *testing.T, b *emulator.Blockchain,
	nftAddr, leagueAddr flow.Address,
	leagueSigner crypto.Signer,
) {

	// check play in match
	play := executeScriptAndCheck(
		t,
		b,
		leagueGenerateScript(GetPlaysInSetPath, nftAddr.String(), leagueAddr.String()),
		[][]byte{jsoncdc.MustEncode(cadence.UInt32(1))},
	)
	assert.EqualValues(t, cadence.NewArray([]cadence.Value{cadence.NewUInt32(1)}), play)

	tx := flow.NewTransaction().
		SetScript(GenerateScript(RetirePlayALLPath, nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(leagueAddr)

	_ = tx.AddArgument(cadence.NewUInt32(1))
	// _ = tx.AddArgument(cadence.NewUInt32(1))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, leagueAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), leagueSigner},
		false,
	)

	isRetired := executeScriptAndCheck(
		t,
		b,
		leagueGenerateScript(GetEditionRetiredPath, nftAddr.String(), leagueAddr.String()),
		[][]byte{jsoncdc.MustEncode(cadence.UInt32(1)), jsoncdc.MustEncode(cadence.UInt32(1))},
	)
	assert.EqualValues(t, cadence.Bool(true), isRetired)
}

func leagueMintItem(
	t *testing.T, b *emulator.Blockchain,
	nftAddr, leagueAddr flow.Address,
	leagueSigner crypto.Signer,
) {
	tx := flow.NewTransaction().
		SetScript(GenerateScript(MintPath, nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(leagueAddr)

	_ = tx.AddArgument(cadence.NewUInt32(1))
	_ = tx.AddArgument(cadence.NewUInt32(1))
	_ = tx.AddArgument(cadence.NewAddress(leagueAddr))
	_ = tx.AddArgument(cadence.NewString("https://this_is_a_pic.jpg"))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, leagueAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), leagueSigner},
		false,
	)

	total := executeScriptAndCheck(
		t,
		b,
		leagueGenerateScript(InspectSupplyPath, nftAddr.String(), leagueAddr.String()),
		nil,
	)
	assert.EqualValues(t, cadence.NewUInt64(1), total)
}

func leagueTransferItem(
	t *testing.T, b *emulator.Blockchain,
	nftAddr, leagueAddr flow.Address, leagueSigner crypto.Signer,
	typeID uint64, recipientAddr flow.Address, shouldFail bool,
) {

	tx := flow.NewTransaction().
		SetScript(leagueGenerateTransferleaguecript(nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(leagueAddr)

	_ = tx.AddArgument(cadence.NewAddress(recipientAddr))
	_ = tx.AddArgument(cadence.NewUInt64(typeID))

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, leagueAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), leagueSigner},
		shouldFail,
	)
}

func newSchedule(
	t *testing.T, b *emulator.Blockchain,
	nftAddr, leagueAddr flow.Address, leagueSigner crypto.Signer,
) {

	tx := flow.NewTransaction().
		SetScript(GenerateScript(StartNewSchedulePath, nftAddr.String(), leagueAddr.String())).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(leagueAddr)

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, leagueAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), leagueSigner},
		false,
	)

	schedule := executeScriptAndCheck(
		t,
		b,
		leagueGenerateScript(GetCurrentSchedulePath, nftAddr.String(), leagueAddr.String()),
		nil,
	)
	assert.EqualValues(t, cadence.NewUInt32(1), schedule)
}

// func TestDeployContracts(t *testing.T) {
// 	b := newEmulator()
// 	DeployContracts(b, t)
// }

func TestCreateLeague(t *testing.T) {
	b := newEmulator()

	nftAddr, leagueAddr, leagueSigner := DeployContracts(b, t)

	supply := executeScriptAndCheck(
		t, b,
		leagueGenerateInspectleaguesupplyScript(nftAddr.String(), leagueAddr.String()),
		nil,
	)
	assert.EqualValues(t, cadence.NewUInt64(0), supply)

	// assert that the account collection is empty
	length := executeScriptAndCheck(
		t,
		b,
		leagueGenerateInspectCollectionLenScript(nftAddr.String(), leagueAddr.String()),
		[][]byte{jsoncdc.MustEncode(cadence.NewAddress(leagueAddr))},
	)
	assert.EqualValues(t, cadence.NewInt(0), length)

	t.Run("Should be able to add a play", func(t *testing.T) {
		createPlay(t, b, nftAddr, leagueAddr, leagueSigner)
	})

	t.Run("Should be able to add a match", func(t *testing.T) {
		createMatch(t, b, nftAddr, leagueAddr, leagueSigner)
	})

	t.Run("Should be able to add play to match", func(t *testing.T) {
		addPlaytoMatch(t, b, nftAddr, leagueAddr, leagueSigner)
	})

	t.Run("Should be able to mint item", func(t *testing.T) {
		leagueMintItem(t, b, nftAddr, leagueAddr, leagueSigner)
	})
}

func TestTransferNFT(t *testing.T) {
	b := newEmulator()

	nftAddr, leagueAddr, leagueSigner := DeployContracts(b, t)

	userAddress, userSigner, _ := createAccount(t, b)

	// create a new Collection for new account
	t.Run("Should be able to create a new empty NFT Collection", func(t *testing.T) {
		leagueSetupAccount(t, b, userAddress, userSigner, nftAddr, leagueAddr)

		length := executeScriptAndCheck(
			t,
			b, leagueGenerateInspectCollectionLenScript(nftAddr.String(), leagueAddr.String()),
			[][]byte{jsoncdc.MustEncode(cadence.NewAddress(userAddress))},
		)
		assert.EqualValues(t, cadence.NewInt(0), length)
	})

	t.Run("Shouldn not be able to withdraw an NFT that does not exist in a collection", func(t *testing.T) {
		nonExistentID := uint64(3333333)

		leagueTransferItem(
			t, b,
			nftAddr, leagueAddr, leagueSigner,
			nonExistentID, userAddress, true,
		)
	})

	// transfer an NFT
	t.Run("Should be able to withdraw an NFT and deposit to another accounts collection", func(t *testing.T) {
		createPlay(t, b, nftAddr, leagueAddr, leagueSigner)
		createMatch(t, b, nftAddr, leagueAddr, leagueSigner)
		addPlaytoMatch(t, b, nftAddr, leagueAddr, leagueSigner)
		leagueMintItem(t, b, nftAddr, leagueAddr, leagueSigner)
		// Cheat: we have minted one item, its ID will be zero
		leagueTransferItem(t, b, nftAddr, leagueAddr, leagueSigner, 1, userAddress, false)
	})

	length := executeScriptAndCheck(
		t,
		b, leagueGenerateInspectCollectionLenScript(nftAddr.String(), leagueAddr.String()),
		[][]byte{jsoncdc.MustEncode(cadence.NewAddress(userAddress))},
	)
	assert.EqualValues(t, cadence.NewInt(1), length)

}

func TestRetire(t *testing.T) {
	b := newEmulator()

	nftAddr, leagueAddr, leagueSigner := DeployContracts(b, t)

	t.Run("Should be able to add a play", func(t *testing.T) {
		createPlay(t, b, nftAddr, leagueAddr, leagueSigner)
		createMatch(t, b, nftAddr, leagueAddr, leagueSigner)
		addPlaytoMatch(t, b, nftAddr, leagueAddr, leagueSigner)
		retirePlay(t, b, nftAddr, leagueAddr, leagueSigner)
	})
}

func TestNewSchedule(t *testing.T) {
	b := newEmulator()

	nftAddr, leagueAddr, leagueSigner := DeployContracts(b, t)

	t.Run("Should be able to add a play", func(t *testing.T) {
		newSchedule(t, b, nftAddr, leagueAddr, leagueSigner)
	})
}

func replaceleagueAddressPlaceholders(code, nftAddress, leagueAddress string) []byte {
	return []byte(replaceImports(
		code,
		map[string]*regexp.Regexp{
			nftAddress:    nftAddressPlaceholder,
			leagueAddress: leagueAddressPlaceHolder,
		},
	))
}

func loadNonFungibleToken() []byte {
	return nft_contracts.NonFungibleToken()
}

func loadLeagueHeros(nftAddr string) []byte {
	return []byte(replaceImports(
		string(readFile(LeagueHerosContractPath)),
		map[string]*regexp.Regexp{
			nftAddr: nftAddressPlaceholder,
		},
	))
	// return replaceleagueAddressPlaceholders(
	// 	string(readFile(LeagueHerosContractPath)),
	// 	nftAddr,
	// 	"0xNFTADDRESS",
	// )
}

func GenerateSetupAccountScript(nftAddr, leagueAddr string) []byte {
	return replaceleagueAddressPlaceholders(
		string(readFile(SetupAccountPath)),
		nftAddr,
		leagueAddr,
	)
}

func GenerateScript(Path, nftAddr, leagueAddr string) []byte {
	return replaceleagueAddressPlaceholders(
		string(readFile(Path)),
		nftAddr,
		leagueAddr,
	)
}

func GenerateMintleaguescript(nftAddr, leagueAddr string) []byte {
	return replaceleagueAddressPlaceholders(
		string(readFile(MintPath)),
		nftAddr,
		leagueAddr,
	)
}

func leagueGenerateTransferleaguecript(nftAddr, leagueAddr string) []byte {
	return replaceleagueAddressPlaceholders(
		string(readFile(TransferPath)),
		nftAddr,
		leagueAddr,
	)
}

func leagueGenerateInspectleaguesupplyScript(nftAddr, leagueAddr string) []byte {
	return replaceleagueAddressPlaceholders(
		string(readFile(InspectSupplyPath)),
		nftAddr,
		leagueAddr,
	)
}

func leagueGenerateInspectCollectionLenScript(nftAddr, leagueAddr string) []byte {
	return replaceleagueAddressPlaceholders(
		string(readFile(InspectCollectionLenPath)),
		nftAddr,
		leagueAddr,
	)
}

func leagueGenerateScript(path, nftAddr, leagueAddr string) []byte {
	return replaceleagueAddressPlaceholders(
		string(readFile(path)),
		nftAddr,
		leagueAddr,
	)
}
