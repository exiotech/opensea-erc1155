pragma solidity ^0.5.11;

import "./ERC1155Tradable.sol";

/**
 * @title MyCollectible
 * MyCollectible - a contract for my semi-fungible tokens.
 */
contract CombMeme is ERC1155Tradable {
    constructor(address _proxyRegistryAddress)
        public
        ERC1155Tradable("CombMeme", "CBM", _proxyRegistryAddress)
    {
        _setBaseMetadataURI("https://api.combme.me/memes/");
    }

    function contractURI() public pure returns (string memory) {
        return "https://api.combme.me/contract/memes-erc115";
    }
}
