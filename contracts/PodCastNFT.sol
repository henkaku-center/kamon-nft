//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ConsensusAdminable.sol";

import {Base64} from "./libraries/Base64.sol";

contract PodCastNFT is ERC721URIStorage, Ownable, ConsensusAdminable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(address[] memory _admin, bool givenHighestAuthority)
        ConsensusAdminable(_admin, givenHighestAuthority)
        ERC721("Henkaku v0.1", "henkaku")
    {}

    mapping(uint256 => bool) private _communityMemberShip;

    function isCommunityMember(uint256 _tokenId) public view returns(bool) {
      return _communityMemberShip[_tokenId];
    }

    function isCommunityMemberByCommunityRole(string memory _roleInCommunity) internal view returns(bool) {
      return bytes(_roleInCommunity).length > 2;
    }

    function updateNFT(
        uint256 tokenId,
        string memory _imageURI,
        string memory _role,
        string memory _roleInCommunity,
        string memory _point
    ) public {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "You are not authorized to update nft"
        );

        _communityMemberShip[tokenId] = isCommunityMemberByCommunityRole(_roleInCommunity);
        string memory finalTokenUri = getTokenURI(tokenId, _imageURI, _role, _roleInCommunity, _point);
        _setTokenURI(tokenId, finalTokenUri);
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

    function getTokenURI(
        uint256 _tokenId,
        string memory _imageURI,
        string memory _role,
        string memory _roleInCommunity,
        string memory _point
    ) internal view returns (string memory) {
        string memory _name = "Membership NFT";
        string memory _description = "The membership card of this Henkaku community represents the contribution of the podcast.\\n\\n"
          "**Special thanks**\\n\\n"
          "NFT Design:\\n\\n"
          "Digital Garage team\\n\\n"
          "Yukinori Hidaka, Saoti Yamaguchi, Masaaki Tsuji, Yuki Sakai, Yuko Hidaka, Masako Inoue, Nanami Nishio, Ruca Takei, Ryu Hayashi.\\n\\n"
          "Engineering:\\n\\n"
          "isbtty, yasek, geeknees";

        bytes memory _attributes;
        if (isCommunityMember(_tokenId)) {
          _attributes = abi.encodePacked(
            '"attributes": [{"trait_type": "Role", "value": "', _role, '"},',
            '{"trait_type": "Henkaku Community member", "value": "', _roleInCommunity, '"},',
            '{"display_type": "number", "trait_type": "Point", "value": "', _point, '"}]'
          );
        } else {
          _attributes = abi.encodePacked(
            '"attributes": [{"trait_type": "Role", "value": "', _role, '"},',
            '{"display_type": "number", "trait_type": "Point", "value": "', _point, '"}]'
          );
        }

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "', _name, '",'
                '"description": "', _description, '",'
                '"image": "', _imageURI, '",',
                string(_attributes),
                "}"
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function mint(
        string memory _imageURI,
        string memory _role,
        string memory _roleInCommunity,
        string memory _point,
        address _to
    ) public returns (uint256) {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "You are not authorized to mint"
        );

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(_to, newItemId);

        _communityMemberShip[newItemId] = isCommunityMemberByCommunityRole(_roleInCommunity);
        string memory finalTokenUri = getTokenURI(newItemId, _imageURI, _role, _roleInCommunity, _point);
        _setTokenURI(newItemId, finalTokenUri);

        return newItemId;
    }
}
