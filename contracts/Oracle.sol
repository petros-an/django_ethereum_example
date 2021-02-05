// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Oracle {

    uint value;
    uint lastUpdateTimestamp;
    uint[] propositions;
    uint bal;
    address[] addresses;
    uint public interval = 3600;
    
    function setInterval( uint i ) external {
        // todo: confirm sender is admin
        interval = i;
    }
    
    function getProposedValues() external view returns (uint[] memory){
        // todo: confirm sender is admin
        return propositions;
    }
    
    function shouldUpdate() internal view returns(bool) {
        return block.timestamp - lastUpdateTimestamp > interval && propositions.length > 10;
    }

    function update() internal {
        // sort proposed values
        // uint[] calldata sortedValues = new uint[](propositions.length);
        // address[] calldata sortedAddresses = new address[] (propositions.length);
        (uint [] memory sortedValues, address[] memory sortedAddresses) = sort(propositions, addresses);
        
        // discard bottom and top 25% of propositions
        (uint left, uint right) = (propositions.length / 4, propositions.length * 3 / 4);
        (uint[] memory trimmedValues, address[] memory trimmedAddresses) = trim(sortedValues, sortedAddresses, left, right);
        
        // calculate value as average of remaining propositions
        value = average(trimmedValues);
        
        // reset data
        delete addresses;
        delete propositions;
        lastUpdateTimestamp = block.timestamp;
        
        // split reward to winners
        for (uint i = 0; i < trimmedAddresses.length; i++ ) {
            pay(payable(trimmedAddresses[i]), bal / trimmedAddresses.length);
        }
    }

    function retrieve() external returns (uint256){
        if (shouldUpdate()) {
            update();
        }
        return value;
    }
    
    function provide(uint proposition) external payable {
        // require(msg.value == 0.01 ether, "Payment of 0.01 ether is required");
        bool alreadyProposed;
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == msg.sender) {
                alreadyProposed = true;
                break;
            }
        }
        require(!alreadyProposed, "Cannot bid twice");
        addresses.push(msg.sender);
        propositions.push(proposition);
        bal += msg.value;
    }
    
    function sort(uint[] storage values, address[] storage addr) internal returns(uint[] memory, address[] memory) {
      quickSort( values, addr, int(0), int(values.length - 1) ) ;
      return (values, addr);
    }
    
    function quickSort(uint[] memory arr, address[] memory add, int left, int right) internal {
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                (add[uint(i)], add[uint(j)]) = (add[uint(j)], add[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, add, left, j);
        if (i < right)
            quickSort(arr, add, i, right);
    }
    
    function average(uint[] memory arr) internal pure returns (uint) {
        uint sum = 0;
        for (uint i = 0; i < arr.length; i++) {
            sum += arr[i];
        }
        return sum / arr.length;
    }
    
    function pay(address payable addr, uint amt) internal  {
        if (addr.send(amt)) {
            bal -= amt;
        }
    }
    
    function trim(uint[] memory arr, address[] memory add, uint left, uint right) internal pure returns(uint[] memory, address[] memory) {
        uint[] memory arrRes = new uint[](right - left);
        address[] memory addRes = new address[](right - left);
        
        for(uint i=left; i < right; i++) {
            arrRes[i - left] = arr[i];
            addRes[i - left] = add[i];
        }
        return (arrRes, addRes);
    }
}
