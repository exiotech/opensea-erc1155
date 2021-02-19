pragma solidity ^0.5.11;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./IKarmaToken.sol";
import "./ERC1155Holder.sol";
import "./CombMeme.sol";

contract Sell is ERC1155Holder, Ownable {
    CombMeme public nft;
    IKarmaToken public karmaToken;
    mapping (uint256=>uint256) orders;

    constructor(address _nft, address _erc20) public {
        nft = CombMeme(_nft);
        karmaToken = IKarmaToken(_erc20);
    }

    function createOrder(uint256 _id, uint256 _price) public onlyOwner {
        require(_price >= 0, "Price need to be more then 0");

        orders[_id] = _price;
    }

    function buy(uint256 _nftId) public {
        require(orders[_nftId] != 0, "Order does not exist");

        karmaToken.burnFrom(msg.sender, _amountOfKarmaToken);
        nft.mint(msg.sender, _nftId, 1, "");
    }
}
