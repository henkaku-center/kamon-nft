//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {IERC20} from "./interface/IERC20.sol";

contract PodCastNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    IERC20 public henkakuToken;

    uint256 public price;
    uint256 public rewardPoint;
    uint256 public rewardHenkaku; 
    address public fundAddress;

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

    mapping(uint256 => string) public _tokenURIs;
    mapping(address => string[]) public roles;
    mapping(address => Attributes) public userAttribute;

    event BoughtMemberShipNFT(address _owner, uint256 _amount);
    event CheckedAnswer(address _by, uint256 _at);
    event ClaimedToken(address _by, uint256 _amount);

    constructor(address _erc20, address _fundAddress)
        ERC721("Henkaku v0.2", "henkaku")
    {
        henkakuToken = IERC20(_erc20);
        setPrice(1000e18);
        setRewardPoint(100);
        setRewardHenkaku(100e18);
        setFundAddress(_fundAddress);
    }

    // override

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
        require(balanceOf(_address) == 0, "MUST BE NONE HOLDER");
        _;
    }

    modifier onlyHolder(address _address) {
        require(balanceOf(_address) != 0, "MUST BE HOLDER");
        _;
    }

    modifier hasTokenId(uint256 _tokenId) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _;
    }

    modifier onlyValidData(string memory _imageURI) {
        // TODO check _imageURL is really valid or not. we might check file extension for example
        require(bytes(_imageURI).length > 0, "Invalid imageURI");
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

    function _mint(
        string memory finalTokenUri,
        string[] memory _roles,
        address _to
    ) internal onlyNoneHolder(msg.sender) returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(_to, newItemId);
        roles[_to] = _roles;
        _setTokenURI(newItemId, finalTokenUri);
        return newItemId;
    }

    // admin function

    function setPrice(uint256 _price) public onlyOwner {
        require(_price >= 1e18, "MUST BE GTE 1e18");
        price = _price;
    }

    function setRewardPoint(uint256 _rewardPoint) public onlyOwner {
        rewardPoint = _rewardPoint;
    }

    function setRewardHenkaku(uint256 _rewardHenkaku) public onlyOwner {
        require(_rewardHenkaku >= 1e18, "MUST BE GTE 1e18");
        rewardHenkaku = _rewardHenkaku;
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

    function updateNFT(uint256 tokenId, string memory _point) public onlyOwner {
        _setTokenURI(tokenId, _tokenURIs[tokenId]);
    }

    function mint(
        string memory _tokenURI,
        string[] memory _roles,
        address _to
    ) public onlyOwner onlyNoneHolder(_to) returns (uint256) {
        return _mint(_tokenURI, _roles, _to);
    }

    function setFundAddress(address _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
    }

    function withdraw() public onlyOwner {
        uint256 _amount = henkakuToken.balanceOf(address(this));
        bool success = henkakuToken.transfer(fundAddress, _amount);
        require(success, "TX FAILED");
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

    function mintWithHenkaku(string memory _tokenURI, uint256 _amount)
        public
        onlyValidData(_tokenURI)
        onlyNoneHolder(msg.sender)
    {
        require(_amount >= price, "INSUFFICIENT AMOUNT");
        bool success = henkakuToken.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        require(success, "TX FAILED");
        string[] memory _roles = new string[](2);
        _roles[0] = "MEMBER";
        _roles[1] = "MINTER";
        _mint(_tokenURI, _roles, msg.sender); // FIXME _point should be numeric type
        emit BoughtMemberShipNFT(msg.sender, _amount);
    }

    function checkAnswer(string memory _keyword) public onlyHolder(msg.sender) {
        require(
            weeklyKeyword.keyword == keccak256(abi.encodePacked(_keyword)),
            "WRONG ANSWER"
        );
        require(
            userAttribute[msg.sender].answeredAt <= weeklyKeyword.startedAt,
            "ALREADY ANSWERED"
        );
        userAttribute[msg.sender].point += rewardPoint;
        userAttribute[msg.sender].claimableToken += rewardHenkaku;
        userAttribute[msg.sender].answeredAt = block.timestamp;
        emit CheckedAnswer(msg.sender, userAttribute[msg.sender].answeredAt);
    }

    function claimToken() public onlyHolder(msg.sender) {
        uint256 amount = userAttribute[msg.sender].claimableToken;
        require(amount > 0, "INSUFFICIENT AMOUNT");
        require(
            henkakuToken.balanceOf(address(this)) >= amount,
            "INSUFFICIENT FOUND"
        );
        bool success = henkakuToken.transfer(msg.sender, amount);
        require(success, "TX FAILED");
        userAttribute[msg.sender].claimableToken = 0;
        emit ClaimedToken(msg.sender, amount);
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }
}
