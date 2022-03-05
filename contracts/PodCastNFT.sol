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

    function isCommunityMember(uint256 _tokenId) public view returns(bool){
      return _communityMemberShip[_tokenId];
    }

    function _communityMember(uint256 _tokenId) internal view returns (string memory) {
      if (isCommunityMember(_tokenId)) {
        return "henkaku community member";
      }
      return "N/A";
    }

    function updateNFT(
        uint256 tokenId,
        string memory _imageURI,
        string memory _role,
        bool _isCommunityMember,
        string memory _point
    ) public {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "You are not authorized to update nft"
        );
        string memory finalTokenUri = getTokenURI(tokenId, _imageURI, _role, _point);
        _communityMemberShip[tokenId] = _isCommunityMember;
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
        string memory _point
    ) internal view returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": ',
                        '"Membership NFT",',
                        '"description": ',
                        '"The membership card of this Henkaku community represents the contribution of the podcast.\\n\\n',
                        "**Special thanks**\\n\\n",
                        "NFT Design:\\n\\n",
                        "Digital Garage team\\n\\n",
                        "Yukinori Hidaka, Saoti Yamaguchi, Masaaki Tsuji, Yuki Sakai, Yuko Hidaka, Masako Inoue, Nanami Nishio, Ruca Takei, Ryu Hayashi.\\n\\n",
                        "Engineering:\\n\\n",
                        'isbtty, yasek, geeknees",',
                        '"image": "',
                        _imageURI,
                        '",',
                        '"attributes": [',
                        '{"trait_type": "Role", "value": "',
                        _role,
                        '"},',
                        '{"trait_type": "Henkaku Community member", "value": "',
                        _communityMember(_tokenId),
                        '"},{"display_type": "number", "trait_type": "Point", "value": "',
                        _point,
                        '"}]}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function mint(
        string memory _imageURI,
        string memory _role,
        string memory _point,
        bool _isCommunityMember,
        address _to
    ) public returns (uint256) {
        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "You are not authorized to mint"
        );

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(_to, newItemId);

        _communityMemberShip[newItemId] = _isCommunityMember;
        string memory finalTokenUri = getTokenURI(newItemId, _imageURI, _role, _point);
        _setTokenURI(newItemId, finalTokenUri);

        return newItemId;
    }
}
