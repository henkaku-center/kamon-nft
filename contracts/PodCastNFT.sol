//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {Base64} from "./libraries/Base64.sol";

contract PodCastNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Henkaku v0.2", "henkaku") {}

    mapping(address => string[]) public roles;
    mapping(uint256 => bool) private _communityMemberShip;

    modifier onlyHolder(address _address) {
        require(balanceOf(_address) != 0, "wallet must have membership nft");
        _;
    }

    function getRoles(address _address) public view returns (string[] memory) {
        return roles[_address];
    }

    function hasRoleOf(address _address, string memory _role)
        public
        view
        returns (bool)
    {
        string[] memory _roles = roles[_address];
        for (uint256 i = 0; i < _roles.length; i++) {
            if (keccak256(bytes(_roles[i])) == keccak256(bytes(_role))) {
                return true;
            }
        }
        return false;
    }

    function setRoles(address _to, string[] memory _roles) public onlyOwner onlyHolder(_to) {
        roles[_to] = _roles;
    }

    function addRole(address _to, string memory _role) public onlyOwner onlyHolder(_to) {
        roles[_to].push(_role);
    }

    function updateOwnNFT(string memory _imageURI, string memory name) public {}

    function updateNFT(
        uint256 tokenId,
        string memory _imageURI,
        string[] memory _roles,
        string memory _point
    ) public onlyOwner {
        string memory finalTokenUri = getTokenURI(
            tokenId,
            _imageURI,
            _roles,
            _point
        );
        _setTokenURI(tokenId, finalTokenUri);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721)
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
        string[] memory _roles,
        string memory _point
    ) internal view returns (string memory) {
        string memory _name = "Membership NFT";
        string
            memory _description = "The membership card of this Henkaku community represents the contribution of the podcast.\\n\\n"
            "**Special thanks**\\n\\n"
            "NFT Design:\\n\\n"
            "Digital Garage team\\n\\n"
            "Yukinori Hidaka, Saoti Yamaguchi, Masaaki Tsuji, Yuki Sakai, Yuko Hidaka, Masako Inoue, Nanami Nishio, Ruca Takei, Ryu Hayashi.\\n\\n"
            "Engineering:\\n\\n"
            "isbtty, yasek, geeknees";

        bytes memory _attributes;
        // TODO implement roles
        _attributes = abi.encodePacked(
            '"attributes": [{"trait_type": "Role", "value": "',
            '"},',
            '{"display_type": "number", "trait_type": "Point", "value": "',
            _point,
            '"}]'
        );

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                _name,
                '",'
                '"description": "',
                _description,
                '",'
                '"image": "',
                _imageURI,
                '",',
                string(_attributes),
                "}"
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function mint(
        string memory _imageURI,
        string[] memory _roles,
        string memory _point,
        address _to
    ) public onlyOwner returns (uint256) {
        require(balanceOf(_to) == 0, "User has had already a memebrship NFT");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(_to, newItemId);
        roles[_to] = _roles;
        // TODO implement getTokenURI with _roles
        string memory finalTokenUri = getTokenURI(
            newItemId,
            _imageURI,
            _roles,
            _point
        );
        _setTokenURI(newItemId, finalTokenUri);
        return newItemId;
    }
}
