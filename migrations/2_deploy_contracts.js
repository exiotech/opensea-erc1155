const CombMeme = artifacts.require("CombMeme");
const Sell = artifacts.require("Sell");
const MyLootBox = artifacts.require("MyLootBox");

// Set to false if you only want the collectible to deploy
const ENABLE_LOOTBOX = false;
// KarmaToken address
const KARMATOKEN = "0xE456F4099ec57d4634678A4Ba503eaE0030A274C"//"rinkeby 0x633a59330141D0585900287767f80CfAd7AF6457";
// Set if you want to create your own collectible
const NFT_ADDRESS_TO_USE = undefined; // e.g. Enjin: '0xfaafdc07907ff5120a76b34b731b278c38d6043c'
// If you want to set preminted token ids for specific classes
const TOKEN_ID_MAPPING = undefined; // { [key: number]: Array<[tokenId: string]> }

module.exports = function(deployer, network) {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress;
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

  if (!ENABLE_LOOTBOX) {
    deployer.deploy(CombMeme, proxyRegistryAddress,  {gas: 5000000}).then(() => {
      return deployer.deploy(Sell, CombMeme.address, KARMATOKEN)
    })
  } else if (NFT_ADDRESS_TO_USE) {
    deployer.deploy(MyLootBox, proxyRegistryAddress, NFT_ADDRESS_TO_USE, {gas: 5000000})
      .then(setupLootbox);
  } else {
    deployer.deploy(CombMeme, proxyRegistryAddress, {gas: 5000000})
      .then(() => {
        deployer.deploy(MyLootBox, proxyRegistryAddress, CombMeme.address, {gas: 5000000}).then(() => {
          return deployer.deploy(Sell, CombMeme.address, KARMATOKEN, {gas: 5000000})
        })
      })
      .then(setupLootbox);
  }
};

async function setupLootbox() {
  if (!NFT_ADDRESS_TO_USE) {
    const collectible = await CombMeme.deployed();
    await collectible.transferOwnership(MyLootBox.address);
  }

  if (TOKEN_ID_MAPPING) {
    const lootbox = await MyLootBox.deployed();
    for (const rarity in TOKEN_ID_MAPPING) {
      console.log(`Setting token ids for rarity ${rarity}`);
      const tokenIds = TOKEN_ID_MAPPING[rarity];
      await lootbox.setTokenIdsForClass(rarity, tokenIds);
    }
  }
}
