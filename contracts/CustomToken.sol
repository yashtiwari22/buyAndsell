// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CustomToken is ERC20, Ownable {
    uint256 private constant _initialSupply = 1000000 * 10 ** 18; // Initial supply of 1,000,000 tokens
    uint256 private constant _maxTransferAmount = 10000 * 10 ** 18; // Max transfer amount to prevent large dumps
    uint256 private _totalBurnedTokens;

    constructor() ERC20("CustomToken", "CTKN") {
        _mint(msg.sender, _initialSupply);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, _applyDeflation(amount));
        return true;
    }

    function _applyDeflation(uint256 amount) private returns (uint256) {
        uint256 burnAmount = amount / 100; // 1% burn rate
        if (_totalBurnedTokens + burnAmount > _initialSupply / 2) {
            burnAmount = (_initialSupply / 2) - _totalBurnedTokens; // Cap burn to 50% of initial supply
        }
        _burn(_msgSender(), burnAmount);
        _totalBurnedTokens += burnAmount;
        return amount - burnAmount;
    }

    function burnTokens(uint256 amount) public onlyOwner {
        _burn(_msgSender(), amount);
        _totalBurnedTokens += amount;
    }

    function totalBurnedTokens() public view returns (uint256) {
        return _totalBurnedTokens;
    }

    function maxTransferAmount() public pure returns (uint256) {
        return _maxTransferAmount;
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Amount sent must be greater than 0");
        uint256 tokenAmount = (msg.value * 10 ** 18) / (1 ether); // Assuming 1 ETH = 10^18 Wei
        require(
            tokenAmount <= _maxTransferAmount,
            "Exceeds max transfer amount"
        );

        _mint(msg.sender, tokenAmount);
    }

    function sellTokens(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        uint256 ethAmount = (amount * 1 ether) / (10 ** 18); // Assuming 1 ETH = 10^18 Wei
        require(ethAmount > 0, "Amount is too small to sell");

        _burn(msg.sender, amount);
        payable(msg.sender).transfer(ethAmount);
    }
}
