//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ConsensusAdminable.sol";

import {Base64} from "./libraries/Base64.sol";
import {Card} from "./libraries/Card.sol";

contract PodCastNFT is ERC721URIStorage, ConsensusAdminable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct NFT {
        string profilePath;
        string handleName;
        string walletAddress;
        string showName;
        string provedBy;
        string role;
        uint256 startDate;
        uint256 endDate;
        uint256 point;
    }

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

    function getSVG() public pure returns (string memory) {
        return Card.svg();
    }

    function mintAndTransfer(address _to) public returns (uint256) {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "You are not authorized to mint"
        );

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        string memory svg = getSVG();
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": ',
                        '"Henkaku PodCast NFT",',
                        '"description": ',
                        '"Henkaku PodCast NFT prototype",',
                        '"image": "',
                        svg,
                        '","image_data": "',
                        svg,
                        '"}'
                    )
                )
            )
        );
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        console.log(finalTokenUri);

        _safeMint(_to, newItemId);
        _setTokenURI(newItemId, finalTokenUri);

        return newItemId;
    }
}
