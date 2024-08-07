// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {StandardBridge} from "../StandardBridge.sol";
import { IERC20 } from "../IERC20.sol";

error L1StandardBridge__NativeTokenExistAlready();

contract L1StandardBridge is StandardBridge {

    address public remoteToken;

    event NativePairSet(
        address indexed localToken,
        address indexed remoteToken,
        bool indexed active
    );

    constructor(){
        owner = msg.sender;
    }


    function setRemoteToken(address _remoteToken) public onlyOwner {
        require(remoteToken == address(0) , "Remote Token Already Exist");
        remoteToken = _remoteToken;
        super.setPairs(address(0), _remoteToken);
        emit NativePairSet(address(0), _remoteToken, true);

    }

    function setPairs(address _localToken, address _remoteToken) public override onlyOwner {
        require(_localToken != remoteToken && _remoteToken != remoteToken, "Native is Already Paired");
        require(_localToken != address(0) && _remoteToken != address(0), "Zero Address Not Allowed");
        super.setPairs(_localToken, _remoteToken);
    }

    function depositNative()
        external
        payable
        onlyPairs(address(0),localToRemote[address(0)])
    {
        require(msg.value > 0 , "More Than Zero");
        _initiateNativeDeposit(msg.sender, msg.sender);
    }

    function depositNativeTo(
        address _to
    ) external payable onlyPairs(address(0),localToRemote[address(0)]) {
        require(msg.value > 0 , "More Than Zero");
        _initiateNativeDeposit(msg.sender, _to);
    }


     function depositERC20(
        address _l1Token,
        uint256 _amount
    )
        external

        onlyPairs(_l1Token,localToRemote[_l1Token]) 

    {
        require(IERC20(_l1Token).balanceOf(msg.sender) >= _amount, "User Don't Have Enough Balance");
        require(IERC20(_l1Token).allowance(msg.sender, address(this)) >= _amount, "Approval not sufficient for bridge operation");
        _initiateERC20Deposit(_l1Token, localToRemote[_l1Token], msg.sender, msg.sender, _amount);
    }

     function depositERC20To(
        address _l1Token,
        address _to,
        uint256 _amount
    )
        external
        onlyPairs(_l1Token,localToRemote[_l1Token]) 
    
    {
        require(IERC20(_l1Token).balanceOf(msg.sender) >= _amount, "User Don't Have Enough Balance");
        require(IERC20(_l1Token).allowance(msg.sender, address(this)) >= _amount, "Approval not sufficient for bridge operation");
        _initiateERC20Deposit(_l1Token, localToRemote[_l1Token], msg.sender, _to, _amount);
    }

    function _initiateERC20Deposit(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _amount
    )
        internal
    {
        _initiateBridgeERC20L1(_l1Token, _l2Token, _from, _to, _amount);
    }

    function _initiateNativeDeposit(
        address _from,
        address _to
    ) internal  {
        _initiateBridgeNative(_from, _to, msg.value);
    }


    function withDrawNative(address _from, address _to, uint _amount) public onlyOwner onlyPairs(remoteToLocal[remoteToken],remoteToken){
        finalizeBridgeNative(address(0), _from, _to, _amount);
    }

    function finalizeERC20Withdrawal(
        address _l1Token,
        address _l2Token,
        address _from,
        address _to,
        uint256 _amount
    )
        public
        onlyOwner
        onlyPairs(_l1Token,_l2Token)
    {
        finalizeBridgeERC20(_l1Token, _l2Token, _from, _to, _amount);
    }

}