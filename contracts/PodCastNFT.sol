//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ConsensusAdminable.sol";

import {Base64} from "./libraries/Base64.sol";

contract PodCastNFT is ERC721URIStorage, ConsensusAdminable {
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

    function updateNFT(uint256 tokenId, string memory _imageURI) public {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "You are not authorized to update nft"
        );
        //TODO update nft
        console.log("Wow epic!!");
        string memory finalTokenUri = getTokenURI(_imageURI);
        _setTokenURI(tokenId, finalTokenUri);
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

    function getTokenURI(string memory _imageURI)
        public
        view
        returns (string memory)
    {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": ',
                        '"Membership NFT",',
                        '"description": ',
                        '"The membership card of this Henkaku community represents the contribution of the podcast",',
                        '"image": "',
                        _imageURI,
                        '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function mintAndTransfer(string memory _imageURI, address _to)
        public
        returns (uint256)
    {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "You are not authorized to mint"
        );

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(_to, newItemId);

        string memory finalTokenUri = getTokenURI(_imageURI);
        _setTokenURI(newItemId, finalTokenUri);

        return newItemId;
    }
}
