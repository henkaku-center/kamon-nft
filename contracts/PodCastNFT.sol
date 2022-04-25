//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {IERC20} from "./interface/IERC20.sol";

contract PodCastNFT is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    IERC20 public henkakuToken;

    uint256 public price;
    address public fundAddress;
    bytes32 private keyword;

    struct PodcastKeyword {
        uint256 startedAt;
        bytes32 keyword;
    }

    struct Attributes {
        uint256 point;
        uint256 claimableToken;
        uint256 answeredAt;
    }

    PodcastKeyword private weeklyKeyword;

    mapping(uint256 => string) private _tokenURIs;
    mapping(address => string[]) private roles;
    mapping(address => Attributes) private userAttribute;

    event BoughtMemberShipNFT(address _owner, uint256 _amount);
    event CheckedAnswer(address _by, uint256 _at);

    constructor(address _erc20, address _fundAddress)
        ERC721("Henkaku v0.2", "henkaku")
    {
        henkakuToken = IERC20(_erc20);
        setPrice(1000e18);
        setFundAddress(_fundAddress);
    }

    // override

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        hasTokenId(tokenId)
        returns (string memory)
    {
        return _tokenURIs[tokenId];
    }

    // modifier

    modifier onlyNoneHolder(address _address) {
        require(balanceOf(_address) == 0, "Address Holds NFT");
        _;
    }

    modifier onlyHolder(address _address) {
        require(balanceOf(_address) != 0, "wallet must have membership nft");
        _;
    }

    modifier hasTokenId(uint256 _tokenId) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _;
    }

    modifier onlyValidData(string memory _imageURI, string memory _name) {
        // TODO check _imageURL is really valid or not. we might check file extension for example
        require(
            bytes(_imageURI).length > 0,
            "Invalid imageURI: Re Enter image url again"
        );
        require(bytes(_name).length > 0, "Invalid name: name cannot be blank");
        _;
    }

    // internal function

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
        hasTokenId(tokenId)
    {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function getTokenURI(
        uint256 _tokenId,
        string memory _imageURI,
        string[] memory _roles,
        string memory _point
    ) internal view returns (string memory) {
        // TODO
        return "";
    }

    function _mint(
        string memory _imageURI,
        string[] memory _roles,
        string memory _point,
        address _to
    ) internal onlyNoneHolder(msg.sender) returns (uint256) {
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

    // admin function

    function setPrice(uint256 _price) public onlyOwner {
        require(_price >= 1e18, "price must be higher than 1e18 wei");
        price = _price;
    }

    function setRoles(address _to, string[] memory _roles)
        public
        onlyOwner
        onlyHolder(_to)
    {
        roles[_to] = _roles;
    }

    function addRole(address _to, string memory _role)
        public
        onlyOwner
        onlyHolder(_to)
    {
        roles[_to].push(_role);
    }

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

    function mint(
        string memory _imageURI,
        string[] memory _roles,
        string memory _point,
        address _to
    ) public onlyOwner returns (uint256) {
        require(balanceOf(_to) == 0, "User has had already a membership NFT");
        return _mint(_imageURI, _roles, _point, _to);
    }

    function setFundAddress(address _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
    }

    function withdraw() public onlyOwner {
        uint256 _amount = henkakuToken.balanceOf(address(this));
        bool success = henkakuToken.transfer(fundAddress, _amount);
        require(success, "Transaction Unsuccessful");
    }

    function burn(uint256 _tokenId) public onlyOwner {
        _burn(_tokenId);
    }

    function setKeyword(string memory _keyword, uint256 startedAt)
        public
        onlyOwner
    {
        weeklyKeyword = PodcastKeyword(
            startedAt,
            keccak256(abi.encodePacked(_keyword))
        );
    }

    // public function

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

    // TODO implement updateNFT func which holder can change their name, imageURL by them self
    function updateOwnNFT(string memory _imageURI, string memory name) public {}

    function mintWithHenkaku(
        string memory _imageURI,
        string memory _name,
        uint256 _amount
    ) public onlyValidData(_imageURI, _name) onlyNoneHolder(msg.sender) {
        require(_amount >= price, "Not Enough Henkaku");
        bool success = henkakuToken.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        require(success, "Token transfer failed");
        string[] memory _roles = new string[](2);
        _roles[0] = "MEMBER";
        _roles[1] = "MINTER";
        _mint(_imageURI, _roles, "1000", msg.sender); // FIXME _point should be numeric type
        emit BoughtMemberShipNFT(msg.sender, _amount);
    }

    function getUserAttributes(address _of)
        public
        view
        returns (Attributes memory)
    {
        return userAttribute[_of];
    }

    function checkAnswer(string memory _keyword) public onlyHolder(msg.sender) {
        bool isCorrect = weeklyKeyword.keyword ==
            keccak256(abi.encodePacked(_keyword));
        require(isCorrect, "Incorrect Answer");
        require(
            userAttribute[msg.sender].answeredAt <= weeklyKeyword.startedAt,
            "You cannot answer twice"
        );
        userAttribute[msg.sender].point += 100;
        userAttribute[msg.sender].claimableToken += 100e18;
        userAttribute[msg.sender].answeredAt = block.timestamp;
        emit CheckedAnswer(msg.sender, userAttribute[msg.sender].answeredAt);
    }

    function claimToken() public onlyHolder(msg.sender) {
        require(
            userAttribute[msg.sender].claimableToken > 0,
            "You don't have claimable token amount"
        );
        require(
            henkakuToken.balanceOf(address(this)) >=
                userAttribute[msg.sender].claimableToken,
            "We don't have enough fund now"
        );
        bool success = henkakuToken.transfer(
            msg.sender,
            userAttribute[msg.sender].claimableToken
        );
        require(success, "Transaction faild");
        userAttribute[msg.sender].claimableToken = 0;
    }
}
