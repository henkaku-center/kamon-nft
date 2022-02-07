//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PodCastNFT is ERC721, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(address[] memory _admins) ERC721("Henkaku NFT", "henkaku") {
      addAdmins(_admins);
    }

    function addAdmins(address[] memory _admins) private {
      for (uint i=0; i < _admins.length; i++) {
        _setupRole(ADMIN_ROLE, _admins[i]);
      }
    }

    function updateNFT(uint256 tokenId) public {
      require(hasRole(ADMIN_ROLE, msg.sender), "You are not authorized to update nft");
      //TODO update nft
      console.log("Wow epic!!");
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
