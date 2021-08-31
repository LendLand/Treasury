// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";



/**
 * @title Treasury
 * @dev This contract locks a specific amount of erc20 for develop team, 
 * and releases every season.
 */
 
contract Treasury is Initializable,OwnableUpgradeable {
    using SafeMath for uint256;

    uint256 public  IntervalFund; // fund releases per interval
    uint256 public StartBlockNumber; // block number when release starts

    uint8 public  MaxRedeemCount; // maximal redeem times
    uint32 public  RedeemInterval; // redeem interval, in blocks
    address  public  RedeemAccount;
    address public Erc20Token;

    uint8 public redeemCount;

    event LogTreasuryRedeem(
        address indexed redeemBy,
        uint8 indexed season,
        uint256 time
    
    );


    function initialize(uint256 _intervalFund,uint8 _maxRedeemCount,uint32 _redeemInterval,uint256 _startBlockNumber,
         address  _redeemAccount,address _token) public initializer {
        IntervalFund = _intervalFund;
        MaxRedeemCount = _maxRedeemCount;
        RedeemInterval = _redeemInterval;
        RedeemAccount = _redeemAccount;
        Erc20Token = _token;
        StartBlockNumber = _startBlockNumber;
        redeemCount = 0;

        OwnableUpgradeable.__Ownable_init();
        
     }
    
    function changeRedeemAccount(address  _account) external onlyOwner{
        RedeemAccount = _account;
    }
    
    /**
     * @dev redeem
     * redeem fund, can redeem only once per season
     */
    function redeem() public  {
        require(redeemCount < MaxRedeemCount, "Fund is empty.");
        require(block.number.sub(StartBlockNumber) >= RedeemInterval * redeemCount, "Next redeemable block in future.");
        require(IERC20(Erc20Token).transfer(RedeemAccount,IntervalFund),"transfer failed");
        redeemCount += 1;
        emit LogTreasuryRedeem(msg.sender, redeemCount, block.timestamp);
    }

    
}
