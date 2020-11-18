pragma solidity ^0.5.11;

import "openzeppelin-solidity/contracts/introspection/ERC165.sol";
import "./IERC1155Receiver.sol";

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() public {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}
