pragma solidity ^0.5.11;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./IKarmaToken.sol";
import "./ERC1155Holder.sol";
import "./CombMeme.sol";

contract Sell is ERC1155Holder, Ownable {
    struct Order {
        uint256 id;
        uint256 price;
        uint256 amount;
    }

    CombMeme public nft;
    IKarmaToken public karmaToken;
    Order[] public orders;

    constructor(address _nft, address _erc20) public {
        nft = CombMeme(_nft);
        karmaToken = IKarmaToken(_erc20);
    }

    function createOrder(uint256 _id, uint256 _amountOfNft, uint256 _price) public onlyOwner {
        require(_amountOfNft > 0, "Price need to be more then 0");
        require(_price > 0, "Price need to be more then 0");

        Order memory order;
        order.id = _id;
        order.price = _price;
        order.amount = _amountOfNft;
        orders.push(order);
    }

    function buy(uint256 _amountOfKarmaToken, uint256 _idForOrders) public {
        require(_amountOfKarmaToken == orders[_idForOrders].price, "Incorrect price");
        require(orders[_idForOrders].price != 0, "Order does not exist");

        karmaToken.burnFrom(msg.sender, _amountOfKarmaToken);
        nft.safeTransferFrom(address(this), msg.sender, orders[_idForOrders].id, orders[_idForOrders].amount, "");
    }
}
