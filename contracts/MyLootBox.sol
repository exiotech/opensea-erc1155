pragma solidity ^0.5.11;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./CombMeme.sol";
import "./MyFactory.sol";
import "./ILootBox.sol";

/**
 * @title MyLootBox
 * MyLootBox - a randomized and openable lootbox of CombMemes
 */
contract MyLootBox is ILootBox, Ownable, Pausable, ReentrancyGuard, MyFactory {
  using SafeMath for uint256;

  event Warning(string message, address account);

  // Must be sorted by rarity
  enum Class {
    Common,
    Rare,
    Epic,
    Legendary,
    Divine,
    Hidden
  }
  uint256 constant NUM_CLASSES = 6;


  mapping (uint256 => uint256[]) public classToTokenIds;
  mapping (uint256 => bool) public classIsPreminted;

  /**
   * @param _proxyRegistryAddress The address of the OpenSea/Wyvern proxy registry
   *                              On Rinkeby: "0xf57b2c51ded3a29e6891aba85459d600256cf317"
   *                              On mainnet: "0xa5409ec958c83c3f309868babaca7c86dcb077c1"
   * @param _nftAddress The address of the non-fungible/semi-fungible item contract
   *                    that you want to mint/transfer with each open
   */
  constructor(
    address _proxyRegistryAddress,
    address _nftAddress
  ) MyFactory(
    _proxyRegistryAddress,
    _nftAddress
  ) public {
  }

  //////
  // INITIALIZATION FUNCTIONS FOR OWNER
  //////

  /**
   * @dev If the tokens for some class are pre-minted and owned by the
   * contract owner, they can be used for a given class by setting them here
   */
  function setClassForTokenId(
    uint256 _tokenId,
    uint256 _classId
  ) public onlyOwner {
    _checkTokenApproval();
    _addTokenIdToClass(Class(_classId), _tokenId);
  }

  /**
   * @dev Alternate way to add token ids to a class
   * Note: resets the full list for the class instead of adding each token id
   */
  function setTokenIdsForClass(
    Class _class,
    uint256[] memory _tokenIds
  ) public onlyOwner {
    uint256 classId = uint256(_class);
    classIsPreminted[classId] = true;
    classToTokenIds[classId] = _tokenIds;
  }

  /**
   * @dev Remove all token ids for a given class, causing it to fall back to
   * creating/minting into the nft address
   */
  function resetClass(
    uint256 _classId
  ) public onlyOwner {
    delete classIsPreminted[_classId];
    delete classToTokenIds[_classId];
  }

  /**
   * @dev Set token IDs for each rarity class. Bulk version of `setTokenIdForClass`
   * @param _tokenIds List of token IDs to set for each class, specified above in order
   */
  function setTokenIdsForClasses(
    uint256[NUM_CLASSES] memory _tokenIds
  ) public onlyOwner {
    _checkTokenApproval();
    for (uint256 i = 0; i < _tokenIds.length; i++) {
      Class class = Class(i);
      _addTokenIdToClass(class, _tokenIds[i]);
    }
  }

  ///////
  // MAIN FUNCTIONS
  //////

  /**
   * @dev Open a lootbox manually and send what's inside to _toAddress
   * Convenience method for contract owner.
   */
  function open(
    uint256 _optionId,
    uint256 _classId,
    address _toAddress,
    uint256 _amount
  ) external onlyOwner {
    _mint(Option(_optionId), Class(_classId), _toAddress, _amount, "");
  }

  /**
   * @dev Main minting logic for lootboxes
   * This is called via safeTransferFrom when MyLootBox extends MyFactory.
   * NOTE: prices and fees are determined by the sell order on OpenSea.
   */
   function _mint(
    Option _option,
    Class _class,
    address _toAddress,
    uint256 _amount,
    bytes memory /* _data */
  ) internal whenNotPaused nonReentrant {
    // Load settings for this box option
    uint256 optionId = uint256(_option);

    require(_canMint(msg.sender, _option, _amount), "MyLootBox#_mint: CANNOT_MINT");

    _sendTokenWithClass(_class, _toAddress, _amount, optionToTokenID[optionId]);
  }

  function _sendTokenWithClass(
    Class _class,
    address _toAddress,
    uint256 _amount,
    uint256 _tokenId /*if 0 create new token*/
  ) internal returns (uint256) {
    uint256 classId = uint256(_class);
    CombMeme nftContract = CombMeme(nftAddress);

    if (classIsPreminted[classId]) {
      nftContract.safeTransferFrom(
        owner(),
        _toAddress,
        _tokenId,
        _amount,
        ""
      );
    } else if (_tokenId == 0) {
      _tokenId = nftContract.create(_toAddress, _amount, "", "");
      classToTokenIds[classId].push(_tokenId);
    } else {
      nftContract.mint(_toAddress, _tokenId, _amount, "");
    }
    return _tokenId;
  }

  /////
  // Metadata methods
  /////

  function name() external view returns (string memory) {
    return "My Loot Box";
  }

  function symbol() external view returns (string memory) {
    return "MYLOOT";
  }

  function uri(uint256 _optionId) external view returns (string memory) {
    return Strings.strConcat(
      baseMetadataURI,
      "box/",
      Strings.uint2str(_optionId)
    );
  }

  /////
  // HELPER FUNCTIONS
  /////

  /**
   * @dev emit a Warning if we're not approved to transfer nftAddress
   */
  function _checkTokenApproval() internal {
    CombMeme nftContract = CombMeme(nftAddress);
    if (!nftContract.isApprovedForAll(owner(), address(this))) {
      emit Warning("Lootbox contract is not approved for trading collectible by:", owner());
    }
  }

  function _addTokenIdToClass(Class _class, uint256 _tokenId) internal {
    uint256 classId = uint256(_class);
    classIsPreminted[classId] = true;
    classToTokenIds[classId].push(_tokenId);
  }
}
