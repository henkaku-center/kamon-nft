//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ConsensusAdminable.sol";

contract PodCastNFT is ERC721, ConsensusAdminable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(address[] memory _admin, bool givenHighestAuthority)
        ConsensusAdminable(_admin, givenHighestAuthority)
        ERC721("Henkaku NFT", "henkaku")
    {}

    receive() external payable {
        console.log(msg.value);
        console.log("receive");
    }

    fallback() external payable {
        console.log(msg.value);
        console.log("fallback");
    }

    function updateNFT(uint256 tokenId) public {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "You are not authorized to update nft"
        );
        //TODO update nft
        console.log("Wow epic!!");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function mintAndTransfer(address _to) public returns (uint256) {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "You are not authorized to mint"
        );
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(_to, newItemId);

        return newItemId;
    }
}
