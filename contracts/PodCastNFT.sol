//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ConsensusAdminable.sol";

contract PodCastNFT is ERC721, ConsensusAdminable {
    constructor(address[] memory _admin, bool givenHighestAuthority) ConsensusAdminable(_admin, givenHighestAuthority) ERC721("Henkaku NFT", "henkaku")  {
      //addInitialAdmins(_admins, false);
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
