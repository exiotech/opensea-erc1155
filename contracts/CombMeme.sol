pragma solidity ^0.5.11;

import "./ERC1155Tradable.sol";

/**
 * @title MyCollectible
 * MyCollectible - a contract for my semi-fungible tokens.
 */
contract CombMeme is ERC1155Tradable {
  constructor(address _proxyRegistryAddress)
  ERC1155Tradable(
    "CombMeme",
    "CBM",
    _proxyRegistryAddress
  ) public {
    _setBaseMetadataURI("https://creatures-api.opensea.io/api/creature/");
  }

  function contractURI() public pure returns (string memory) {
    return "https://creatures-api.opensea.io/contract/opensea-erc1155";
  }
}
