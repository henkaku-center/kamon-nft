//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {IERC20} from "./interface/IERC20.sol";

contract KamonNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    IERC20 public henkakuToken;

    uint256 public price;
    uint256 public rewardPoint;
    uint256 public rewardHenkaku;
    address public fundAddress;
    string private _contractURI;

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

    event BoughtMemberShipNFT(address _owner, uint256 _tokenId);
    event CheckedAnswer(address _by, uint256 _at);
    event ClaimedToken(address _by, uint256 _amount);

    constructor(address _erc20, address _fundAddress)
        ERC721("Henkaku v0.2", "henkaku")
    {
        setTokenAddr(_erc20);
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

    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual override {
        roles[_to] = roles[_from];
        delete roles[_from];
        userAttribute[_to] = userAttribute[_from];
        delete userAttribute[_from];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public virtual override onlyOwner {
        _transfer(_from, _to, _tokenId);
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

    function updateNFT(uint256 tokenId, string memory finalTokenUri)
        public
        onlyOwner
    {
        _setTokenURI(tokenId, finalTokenUri);
    }

    function mint(
        string memory _tokenURI,
        string[] memory _roles,
        address _to
    ) public onlyOwner onlyNoneHolder(_to) returns (uint256) {
        return _mint(_tokenURI, _roles, _to);
    }

    function giveAwayPoint(
        address _to,
        uint256 _point,
        uint256 _claimableToken
    ) public onlyOwner onlyHolder(_to) {
        userAttribute[_to].point += _point;
        userAttribute[_to].claimableToken += _claimableToken;
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

    function setKeyword(bytes32 _keyword, uint256 startedAt) public onlyOwner {
        weeklyKeyword = PodcastKeyword(startedAt, _keyword);
    }

    function setTokenAddr(address _erc20) public onlyOwner {
        henkakuToken = IERC20(_erc20);
    }

    function setContractURI(string memory uri) public onlyOwner {
        _contractURI = uri;
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

    function updateOwnNFT(uint256 tokenId, string memory finalTokenUri) public {
        require(ownerOf(tokenId) == msg.sender, "NOT NFT OWNER");
        _setTokenURI(tokenId, finalTokenUri);
    }

    function mintWithHenkaku(string memory _tokenURI, uint256 _amount)
        public
        onlyNoneHolder(msg.sender)
    {
        require(bytes(_tokenURI).length > 0, "Invalid tokenURI");
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
        uint256 newItemId = _mint(_tokenURI, _roles, msg.sender);
        emit BoughtMemberShipNFT(msg.sender, newItemId);
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

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }
}
