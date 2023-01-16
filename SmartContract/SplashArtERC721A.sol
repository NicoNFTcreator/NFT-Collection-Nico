// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

//@author Nico.NFTcreator
//@title the Colorful Warriors

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721A.sol";
import "./IERC721A.sol";

contract TheColorfulWarriorERC721A is Ownable, ERC721A {

    using Strings for uint;

    enum Step {
        Before,
        WhitelistSale,
        PublicSale,
        SoldOut,
        Reveal
    }

    string public baseURI;

    Step public sellingStep;

    uint private constant MAX_SUPPLY = 799;
    uint private constant MAX_WHITELIST = 200;
    uint private constant MAX_PUBLIC = 596;
    uint private constant MAX_GIFT = 3;

    uint public wlSalePrice = 0.008 ether;
    uint public publicSalePrice = 0.009 ether;

    bytes32 public merkleRoot;

    uint public saleStartTime = 1646737200;

    mapping(address => uint) public amountNFTsperWalletWhitelistSale;

    constructor(bytes32 _merkleRoot, string memory _baseURI) ERC721A("the Colorful Warriors", "WARRIORS")
    {
        merkleRoot = _merkleRoot;
        baseURI = _baseURI;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function whitelistMint(address _account, uint _quantity, bytes32[] calldata _proof) external payable callerIsUser {
        uint price = wlSalePrice;
        require(price != 0, "Price is 0");
        require(currentTime() >= saleStartTime, "Whitelist Sale has not started yet");
        require(currentTime() < saleStartTime + 60 minutes, "Whitelist Sale is finished");
        require(sellingStep == Step.WhitelistSale, "Whitelist sale is not activated");
        require(isWhiteListed(msg.sender, _proof), "Not whitelisted");
        require(amountNFTsperWalletWhitelistSale[msg.sender] + _quantity <= 3, "You can only get 3 NFT on the Whitelist Sale");
        require(totalSupply() + _quantity <= MAX_WHITELIST, "Max supply exceeded");
        require(msg.value >= price * _quantity, "Not enought funds");
        amountNFTsperWalletWhitelistSale[msg.sender] += _quantity;
        _safeMint(_account, _quantity);
    }

    function publicSaleMint(address _account, uint _quantity) external payable callerIsUser {
        uint price = publicSalePrice;
        require(price != 0, "Price is 0");
        require(sellingStep == Step.PublicSale, "Public sale is not activated");
        require(totalSupply() + _quantity <= MAX_WHITELIST + MAX_PUBLIC, "Max supply exceeded");
        require(msg.value >= price * _quantity, "Not enought funds");
        _safeMint(_account, 51);
        _safeMint(_account, 151);
        _safeMint(_account, 564);
        _safeMint(_account, _quantity);
    }

    function gift(address _to, uint _quantity) external onlyOwner {
        require(sellingStep > Step.PublicSale, "Gift is after the public sale");
        require(totalSupply() + _quantity <= MAX_SUPPLY, "Reached max Supply");
        _safeMint(_to, _quantity);
    }

    function setSaleStartTime(uint _saleStartTime) external onlyOwner {
        saleStartTime = _saleStartTime;
    }

    function setBaseUri(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function currentTime() internal view returns(uint) {
        return block.timestamp;
    }

    function setStep(uint _step) external onlyOwner {
        sellingStep = Step(_step);
    }

    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "URI query for nonexistent token");

        return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
    }

    //Whitelist
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function isWhiteListed(address _account, bytes32[] calldata _proof) internal view returns(bool) {
        return _verify(leaf(_account), _proof);
    }

    function leaf(address _account) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 _leaf, bytes32[] memory _proof) internal view returns(bool) {
        return MerkleProof.verify(_proof, merkleRoot, _leaf);
    }

}
